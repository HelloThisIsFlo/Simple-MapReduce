defmodule SimpleMapreduceTest do
  alias SimpleMapreduce.Supervisors.WorkerFactory
  alias SimpleMapreduce.Mocks
  use ExUnit.Case

  @moduletag :capture_log

  @config Application.fetch_env!(:simple_mapreduce, :config_module)

  setup(context) do
    Mocks.HeavyWork.start_mock_and_subscribe
    WorkerFactory.start_link :extra_worker_factory

    pipeline = context[:pipeline]
    workers = context[:workers]
    if pipeline do
      SimpleMapreduce.start_new_pipeline(pipeline)
      add_workers(pipeline, workers)
    end

    :ok
  end

  def add_workers(pipeline, number_workers)
  def add_workers(_pipeline, 0), do: :nothing
  def add_workers(pipeline, number) when number > 0 do
    for _ <- 1..number do
      SimpleMapreduce.add_worker(pipeline)
    end
  end


  test "start a new pipeline" do
    # Given: Pipeline is not started
    name = "pipeline-name"
    assert nil == name |> @config.producer_id |> GenServer.whereis
    assert nil == name |> @config.anchor_id |> GenServer.whereis

    # When: Starting a new pipeline
    SimpleMapreduce.start_new_pipeline "pipeline-name"

    # Then: Pipeline is started, and worker can be added
    refute nil == name |> @config.producer_id |> GenServer.whereis
    refute nil == name |> @config.anchor_id |> GenServer.whereis

    assert {:ok, worker_pid} = SimpleMapreduce.add_worker name
    refute nil == worker_pid
  end

  test "emtpy list" do
    {:ok, processed_events} = SimpleMapreduce.do_heavy_work_on_all_elements([], "no-pipeline-needed")
    assert processed_events == []
  end

  @tag workers: 1
  @tag pipeline: "process-all"
  test "process all elements" do
    # Given: Pipeline is started (see tag)
    # When: processing 3 events
    list = [element(1), element(2), element(3)]
    {:ok, processed_events} = SimpleMapreduce.do_heavy_work_on_all_elements(list, "process-all")

    # Then: all events are synchronously processed
    assert is_list(processed_events)
    assert 3 == length(processed_events)
  end

  @tag workers: 0
  @tag pipeline: "using-extra-workers"
  test "using extra workers" do
    # Given: Pipeline is started, with no workers (see tag)
    # When: adding an extra worker
    SimpleMapreduce.add_extra_worker("using-extra-workers")

    # Then: Worker is on the extra factory & HeavyWork works
    regular_factory = @config.workerfactory_id("using-extra-workers")
    extra_worker_factory = SimpleMapreduce.Supervisors.ExtraWorkerFactory
    %{active: workers_on_regular_factory} = Supervisor.count_children(regular_factory)
    %{active: workers_on_extra_factory}   = Supervisor.count_children(extra_worker_factory)
    assert 0 == workers_on_regular_factory, "Worker is on the wrong supervisor/factory"
    assert 1 == workers_on_extra_factory,   "Worker is on the wrong supervisor/factory"

    list = [element(1), element(2), element(3)]
    {:ok, processed_events} = SimpleMapreduce.do_heavy_work_on_all_elements(list, "using-extra-workers")
    assert is_list(processed_events)
    assert 3 == length(processed_events)
  end

  @tag workers: 1
  @tag pipeline: "crash"
  test "crash while processing, test stays alive" do
    # Given: Mock is set to crash on work
    Mocks.HeavyWork.activate_crash_on_work

    anchor_original_pid = GenServer.whereis(@config.anchor_id("crash"))
    refute nil == anchor_original_pid

    # When: processing error happens
    list = [element(1), element(2), element(3)]
    SimpleMapreduce.do_heavy_work_on_all_elements(list, "crash", 100)

    # Then: Anchor is still alive and wasn't restarted
    anchor_pid = GenServer.whereis(@config.anchor_id("crash"))
    refute nil == anchor_pid
  end

  @tag workers: 1
  @tag pipeline: "crash"
  test "crash while working, anchor stays alive" do
    # Given: Mock is set to crash on work
    Mocks.HeavyWork.activate_crash_on_work

    anchor_original_pid = GenServer.whereis(@config.anchor_id("crash"))
    refute nil == anchor_original_pid

    # When: processing error happens
    list = [element(1), element(2), element(3)]
    SimpleMapreduce.do_heavy_work_on_all_elements(list, "crash", 100)

    # Then: Anchor is still alive and wasn't restarted
    anchor_pid = GenServer.whereis(@config.anchor_id("crash"))
    refute nil == anchor_pid
    assert anchor_original_pid == anchor_pid
  end

  @tag workers: 1
  @tag pipeline: "crash"
  test "crash while working, still get non-affected batch" do
    # Given: Mock crashes once & workers handle events 2by2 (see test config file)
    Mocks.HeavyWork.activate_crash_on_work 1

    # When: processing 5 elements
    list = [element(1), element(2), element(3), element(4), element(5)]
    {:timeout, result} = SimpleMapreduce.do_heavy_work_on_all_elements(list, "crash", 100)

    # Then:
    # First batch of 2 elements will be lost because processed on a worker that crashed
    # but the second batch should be handled by a new worker which will not crash
    # (Mocks has been set to crash only once)
    assert 3 == length(result)
  end

  @tag workers: 1
  @tag pipeline: "dead-lock"
  @tag :skip
  test "simulate dead-lock" do
    list = element(1) |> List.duplicate(3000)
    for i <- 1..100 do
      IO.inspect i
      assert_do_heavy_work_on_all_elements("dead-lock", list)
    end
  end

  def assert_do_heavy_work_on_all_elements(pipeline_name, elements) do
    {:ok, processed_events} = SimpleMapreduce.do_heavy_work_on_all_elements(elements, pipeline_name)
    assert is_list(processed_events)
    assert length(elements) == length(processed_events)
  end

  def element(index) do
    "json" <> to_string(index)
  end
end
