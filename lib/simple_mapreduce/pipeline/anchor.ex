defmodule SimpleMapreduce.Pipeline.Anchor do
  alias SimpleMapreduce.Pipeline.Config
  use GenStage
  require Logger

  @moduledoc """
  Defines an Anchor that stays on the main machine to collect the work of all
  workers running on different nodes of the cluster.

  Each time a new worker is spawned it will ask the anchor to monitor it.
  This is possible because the Anchor has a stable Name/Node couple.
  """

  def start_link(pipeline_name) do
    GenStage.start_link(__MODULE__, :ok, name: Config.anchor_id(pipeline_name))
  end


  ##########################
  ##  GenStage callbacks  ##
  ##########################
  def init(:ok) do
    {:producer_consumer, :no_state}
  end

  def handle_events(processed_events, _from, _state) do
    log_events(processed_events)
    #Dispatch events to subscribers
    {:noreply, processed_events, :no_state}
  end

  defp log_events(processed_events) do
    count = Enum.count(processed_events)
    Logger.info("Processed events: #{count}")
  end

end
