defmodule SimpleMapreduce.Application do
  alias SimpleMapreduce.Supervisors.PipelineFactory
  alias SimpleMapreduce.Supervisors.WorkerFactory
  alias SimpleMapreduce.Pipeline.Config
  use Application

  def start(_type, _args) do
    if main_node?() do
      PipelineFactory.start_link
    else
      WorkerFactory.start_link :extra_worker_factory
    end
  end

  defp main_node? do
    node() == Config.main_node
  end

end
