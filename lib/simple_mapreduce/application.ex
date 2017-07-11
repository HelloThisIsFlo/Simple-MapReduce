defmodule SimpleMapreduce.Application do
  alias SimpleMapreduce.Supervisors.PipelineFactory
  alias SimpleMapreduce.Supervisors.WorkerFactory
  use Application

  @config Application.fetch_env!(:simple_mapreduce, :config_module)

  def start(_type, _args) do
    if main_node?() do
      PipelineFactory.start_link
    else
      WorkerFactory.start_link :extra_worker_factory
    end
  end

  defp main_node? do
    node() == @config.main_node
  end

end
