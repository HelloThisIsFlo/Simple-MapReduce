defmodule SimpleMapreduce.Pipeline.Producer do
  use GenStage

  @config Application.fetch_env!(:simple_mapreduce, :config_module)

  @moduledoc """

  Producer of events that buffers demand when no events are available.

  """

  def start_link(pipeline_name) do
    GenStage.start_link(__MODULE__, :ok, name: @config.producer_id(pipeline_name))
  end

  def add_element_list(pipeline_name, element_list) when is_list(element_list) do
    GenStage.call(@config.producer_id(pipeline_name), {:add, element_list})
  end


  ##########################
  ##  GenStage callbacks  ##
  ##########################
  def init(:ok) do
    json_list = []
    pending_demand = 0
    {:producer, {json_list, pending_demand}}
  end

  def handle_demand(demand, {list, pending_demand}) when demand > 0 do
    demand = demand + pending_demand

    {events, list, pending_demand} = compute_events_and_new_state(demand, list)
    {:noreply, events, {list, pending_demand}}
  end

  def handle_call({:add, new_elements}, _from, {list, pending_demand}) when is_list(new_elements) do
    list = list ++ new_elements

    {events, list, pending_demand} = compute_events_and_new_state(pending_demand, list)
    {:reply, :ok, events, {list, pending_demand}}
  end
  def handle_call({:add, _new_elements}, _from, {list, _pending_demand}) do
    {:stop, :shutdown, list}
  end



  def compute_events_and_new_state(demand, available_events) when demand > length(available_events) do
    # Return all and store pending demand
    pending_demand = demand - length(available_events)
    {available_events, [], pending_demand}
  end
  def compute_events_and_new_state(demand, available_events) do
    # Return according to demand
    {demanded, remaining} = Enum.split(available_events, demand)
    {demanded, remaining, 0}
  end


end
