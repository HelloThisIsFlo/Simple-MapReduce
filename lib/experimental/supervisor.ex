defmodule Experimental.Supervisor do
  use Supervisor
  import Supervisor.Spec

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end



  ##############################
  ###   Supervisor Callbacks ###
  ##############################
  def init(:ok) do
    children = [
      supervisor(Task.Supervisor, [[name: Experimental.RoutingTasks]], id: RoutingTasks),
      supervisor(Task.Supervisor, [[name: Experimental.HeavyWorkTasks]], id: HeavyWorkTasks),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
