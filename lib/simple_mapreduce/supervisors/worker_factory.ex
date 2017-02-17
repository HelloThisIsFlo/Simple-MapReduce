defmodule SimpleMapreduce.Supervisors.WorkerFactory do
  alias SimpleMapreduce.Pipeline.Config
  import Supervisor.Spec
  use Supervisor
  require Logger

  @extra_worker_factory SimpleMapreduce.Supervisors.ExtraWorkerFactory

  @doc """
  To link the worker factory to a specific pipeline: use the pipeline name.

  To spawn an extra worker factory (slave nodes): use `:extra_worker_factory` in place of the pipeline name
  (only for `start_link`)
  """
  @type pipeline_name :: String.t
  @spec start_link(pipeline_name | :extra_worker_factory) :: {:ok, pid}
  def start_link(pipeline_name) do
    Supervisor.start_link(__MODULE__, :ok, name: workerfactory_id(pipeline_name))
  end

  def add_worker(pipeline_name, node, extra_worker \\ false)
  def add_worker(pipeline_name, node, true) do
    Logger.info "Starting extra worker | Pipeline = #{pipeline_name} | Node = #{inspect node}"
    Supervisor.start_child({@extra_worker_factory, node}, [pipeline_name])
  end
  def add_worker(pipeline_name, node, false) do
    Logger.info "Starting worker | Pipeline = #{pipeline_name} | Node = #{inspect node}"
    Supervisor.start_child({Config.workerfactory_id(pipeline_name), node}, [pipeline_name])
  end

  def workerfactory_id(:extra_worker_factory), do: @extra_worker_factory
  def workerfactory_id(pipeline_name), do: Config.workerfactory_id(pipeline_name)

  ###########################
  ##  Supervisor callbacks ##
  ###########################

  def init(:ok) do
    children = [worker(SimpleMapreduce.Pipeline.Worker,
                       [],
                       function: :add_worker,
                       restart: :permanent)]

    supervise(children, strategy: :simple_one_for_one)
  end


end
