defmodule SimpleMapreduce.Supervisors.Pipeline do
  alias SimpleMapreduce.Pipeline.Config
  import Supervisor.Spec
  use Supervisor
  require Logger

  def start_link(pipeline_name) do
    Supervisor.start_link(__MODULE__, pipeline_name, name: Config.pipeline_id(pipeline_name))
  end


  ##############################
  ###   Supervisor Callbacks ###
  ##############################
  def init(pipeline_name) do
    Logger.info "Starting a new Pipeline | Name = #{pipeline_name}"

    children = [
      # Start Main Producer / Consumer
      worker(SimpleMapreduce.Pipeline.Producer, [pipeline_name]),
      worker(SimpleMapreduce.Pipeline.Anchor, [pipeline_name]),

      # Start Worker supervisor
      supervisor(SimpleMapreduce.Supervisors.WorkerFactory, [pipeline_name])
    ]

    supervise(children, strategy: :one_for_one)
  end

end
