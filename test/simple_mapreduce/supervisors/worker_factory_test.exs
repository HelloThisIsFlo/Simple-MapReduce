defmodule SimpleMapreduce.Supervisors.WorkerFactoryTest do
  alias SimpleMapreduce.Supervisors.WorkerFactory
  alias SimpleMapreduce.Pipeline.Config
  alias SimpleMapreduce.Pipeline.Worker
  alias SimpleMapreduce
  use ExUnit.Case

  @moduletag :capture_log

  test "get the correct workerfactory id for REGULAR workerfactory" do
    {:ok, pid} = WorkerFactory.start_link "regular"

    expected_name = Config.workerfactory_id "regular"
    assert expected_name ==  Process.info(pid)[:registered_name]
  end

  test "get the correct workerfactory id for EXTRA workerfactory" do
    {:ok, pid} = WorkerFactory.start_link :extra_worker_factory

    expected_name =  SimpleMapreduce.Supervisors.ExtraWorkerFactory
    assert expected_name ==  Process.info(pid)[:registered_name]
  end

  test "add regular worker", context do
    # Given: Pipeline is started
    pipeline_name = to_string(context.test)
    SimpleMapreduce.start_new_pipeline pipeline_name

    # When: Adding new workers
    {:ok, worker_pid} = WorkerFactory.add_worker(pipeline_name, node())

    # Then: Worker is added
    factory = Config.workerfactory_id(pipeline_name)
    worker_module = Worker
    assert [{_, ^worker_pid, _, [^worker_module]}] = Supervisor.which_children(factory)
  end

  test "add extra worker", context do
    # Given: Pipeline is started, Extra WorkerFactory is started
    pipeline_name = to_string(context.test)
    SimpleMapreduce.start_new_pipeline pipeline_name
    WorkerFactory.start_link :extra_worker_factory

    # When: Adding new workers
    {:ok, worker_pid} = WorkerFactory.add_worker(pipeline_name, node(), true)

    # Then: Worker is added to the correct factory
    regular_factory = Config.workerfactory_id(pipeline_name)
    extra_worker_factory = SimpleMapreduce.Supervisors.ExtraWorkerFactory
    assert %{active: 0} = Supervisor.count_children(regular_factory)
    assert %{active: 1} = Supervisor.count_children(extra_worker_factory)
    assert [{_, ^worker_pid, _, [Worker]}] = Supervisor.which_children(extra_worker_factory)
  end
end
