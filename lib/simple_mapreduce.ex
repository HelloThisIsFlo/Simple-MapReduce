defmodule SimpleMapreduce do
  alias SimpleMapreduce.Supervisors.PipelineFactory
  alias SimpleMapreduce.Supervisors.WorkerFactory
  alias SimpleMapreduce.Pipeline.Producer
  use GenStage
  require Logger
  @behaviour SimpleMapreduce.Behaviour

  @config Application.fetch_env!(:simple_mapreduce, :config_module)

  @moduledoc """
  Api to access the 'SimpleMapreduce' Application.
  Transfoms the whole pipeline into a synchronous function call.
  """

  defmodule Behaviour do
    @type pipeline_name :: String.t

    @callback do_heavy_work_on_all_elements([any], pipeline_name, timeout) :: any

    @callback start_new_pipeline(pipeline_name) :: :ok | any
    @callback add_worker(pipeline_name, node) :: :ok | any
    @callback add_extra_worker(pipeline_name, node) :: :ok | any
  end


  @default_worker_node @config.workers_node()
  @timeout 3000

  def start_new_pipeline(pipeline_name) do
    PipelineFactory.start_new_pipeline pipeline_name
  end

  def add_worker(pipeline_name, node \\ @default_worker_node) do
    WorkerFactory.add_worker pipeline_name, node
  end

  def add_extra_worker(pipeline_name, node \\ @default_worker_node) do
    WorkerFactory.add_worker pipeline_name, node, true
  end



  def do_heavy_work_on_all_elements(elements, pipeline_name, timeout \\ @timeout)
  def do_heavy_work_on_all_elements([], _, _), do: {:ok, []}
  def do_heavy_work_on_all_elements(elements, pipeline_name, timeout) when is_list(elements) do
    Logger.info "Processing #{Enum.count elements} elements | Pipeline=#{pipeline_name}"
    expected_count = length(elements)
    callback_pid = self()
    {:ok, sync_pid} = GenStage.start_link(__MODULE__, {pipeline_name, callback_pid, expected_count})

    Producer.add_element_list(pipeline_name, elements)

    receive do
      {:result, processed} ->
        {:ok, processed}
    after
      timeout ->
        {:timeout, GenServer.call(sync_pid, :get_events_now)}
    end
  end

  ###########################
  ###  GenStage callbacks ###
  ###########################
  def init({pipeline_name, callback_pid, expected_count}) do
    anchor = @config.anchor_id(pipeline_name)
    processed = []
    {:consumer, {expected_count, processed, callback_pid}, subscribe_to: [{anchor, [cancel: :temporary]}]}
  end

  def handle_events(new_events, _from, {expected_count, processed, callback_pid}) do
    processed = processed ++ new_events
    if length(processed) == expected_count do
      send callback_pid, {:result, processed}
      {:stop, :normal, :no_state}
    else
      {:noreply, [], {expected_count, processed, callback_pid}}
    end
  end

  def handle_call(:get_events_now, from, {_, processed, _}) do
    GenServer.reply(from, processed)
    {:stop, :normal, :no_state}
  end

end
