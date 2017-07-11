defmodule SimpleMapreduce.Pipeline.WorkerTest do
  alias SimpleMapreduce.Pipeline.Worker
  alias SimpleMapreduce.Supervisors.PipelineFactory
  alias SimpleMapreduce.Supervisors.WorkerFactory
  alias SimpleMapreduce.Mocks
  use ExUnit.Case

  @moduletag :capture_log
  @config Application.fetch_env!(:simple_mapreduce, :config_module)

  setup(context) do
    Application.stop(:sr_distributed)
    Application.start(:sr_distributed)

    # Start a new pipeline and add a worker
    pipeline_name = to_string(context.test)
    PipelineFactory.start_new_pipeline(pipeline_name)
    WorkerFactory.add_worker(pipeline_name, node())

    # Start the parser mock
    Mocks.HeavyWork.start_mock_and_subscribe

    [pipeline_name: pipeline_name]
  end

  test "parse json with correct sport and provider" do
    # Given: Single event
    event = ["event"]

    # When: HeavyWork
    {:noreply, _processec, _state} = Worker.handle_events(event, nil, nil)
    # Then: use the correct sport/provider (calls the mock implementation)
    # (HeavyWorkMock sends a message)
    assert_receive {:work, "event"}
  end

  test "parse multiple json1s" do
    # Given: A list with 10 events
    number_of_events = 10
    events = "json1" |> List.duplicate(number_of_events)

    # When: HeavyWork multiple events
    {:noreply, _, _} = Worker.handle_events(events, nil, nil)
    # Then: all events are parsed
    # (HeavyWorkMock sends a message)
    for _ <- 1..number_of_events do
      assert_receive {:work, "json1"}
    end
  end

  test "worker connects to pipeline", %{pipeline_name: pipeline_name} do
    # Given: Producer and Anchor are up
    producer = GenServer.whereis(@config.producer_id(pipeline_name))
    anchor = GenServer.whereis(@config.anchor_id(pipeline_name))
    assert nil != producer
    assert nil != anchor

    # When: Adding new worker
    {:ok, worker} = Worker.add_worker(pipeline_name)
    # Then: Worker worker subscribed to Producer and registered with Anchor
    assert_subscribed(anchor, to: worker)
    assert_subscribed(worker, to: producer)
  end

  @tag :skip
  test "main node"


  def assert_subscribed(consumer, to: producer) do
    number_of_references_to_consumer = producer
                                        |> :sys.get_state
                                        |> Map.get(:consumers, %{})
                                        |> Enum.count(fn({_key, {consumer_pid, _consumer_ref}}) ->
                                          consumer_pid == consumer
                                        end)

    assert number_of_references_to_consumer > 0, "Consumer is not subscribed to producer"
  end


  def json_element(index) do
    {:football, :runningball, "json" <> to_string(index)}
  end
end
