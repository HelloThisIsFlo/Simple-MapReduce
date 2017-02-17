defmodule SimpleMapreduce.Supervisors.PipelineFactory do
  import Supervisor.Spec
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_new_pipeline(pipeline_name) do
    Supervisor.start_child(__MODULE__, [pipeline_name])
  end

  ############################
  ##  Supervisor callbacks  ##
  ############################
  def init(:ok) do
    children = [
      supervisor(SimpleMapreduce.Supervisors.Pipeline, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

end
