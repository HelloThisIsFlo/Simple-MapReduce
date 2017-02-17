defmodule SimpleMapreduce.Pipeline.Worker do
  alias SimpleMapreduce.Pipeline.Config
  use GenStage
  require Logger

  @doc"""
  Starts a `SimpleMapreduce.Pipeline.Worker` worker, and connect it to the pipeline.
  """
  def add_worker(pipeline_name) do
    {:ok, worker} = GenStage.start_link(__MODULE__, :ok)
    add_to_chain(pipeline_name, worker)
    {:ok, worker}
  end

  @main_node  Config.main_node()
  @heavy_work Config.heavy_work_module()
  @max_demand Config.max_demand()

  defp add_to_chain(pipline_name, worker) do
    json_producer = Config.producer_id(pipline_name)
    anchor = Config.anchor_id(pipline_name)

    # Ask final Consumer to subscribe to worker
    GenStage.sync_subscribe {anchor, @main_node}, to: worker, cancel: :temporary

    # Subscribe to Producer
    GenStage.sync_subscribe worker, to: {json_producer, @main_node}, max_demand: @max_demand, min_demand: 0

    # Note about the option:
    # min_demand: 0  -> specify that the worker will consume all events before requesting new ones
    # 0 minimum "pending" demand (See GenStage test suite for expected behavior, they are very explicit)
  end


  ##########################
  ##  GenStage callbacks  ##
  ##########################
  def init(:ok) do
    {:producer_consumer, :no_state}
  end

  def handle_events(events_to_process, _from, state) do
    Logger.info "Heavy_Work #{Enum.count events_to_process} | worker=#{inspect self()} node=#{inspect node()}"

    processed = events_to_process
    |> Task.async_stream(&@heavy_work.do_heavy_work/1, [])
    |> Enum.to_list
    |> Enum.map(fn({:ok, processed}) -> processed end)

    {:noreply, processed, state}
  end

end
