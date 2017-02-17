defmodule SimpleMapreduce.Pipeline.ProducerTest do
  alias SimpleMapreduce.Pipeline.Producer
  use ExUnit.Case

  test "state at init" do
    assert {:producer, state} = Producer.init(:ok)
    assert {[], 0} = state
  end

  test "enough elements => fire events, no pending demand" do
    # Given: 5 elements in the list
    previous_json_list = [
      json_element(1),
      json_element(2),
      json_element(3),
      json_element(4),
      json_element(5)
    ]
    previous_state = {previous_json_list, 0}

    # When: Requesting less events than size of the list
    {:noreply, events, {json_list, pending_demand}} = Producer.handle_demand(3, previous_state)

    # Then: Fire events, store remaining events, no pending demand
    assert events == [json_element(1), json_element(2), json_element(3)]
    assert json_list == [json_element(4), json_element(5)]
    assert pending_demand == 0
  end

  test "not enough elements => fire all remaining events, store pending demand" do
    # Given: 3 elements in the list
    previous_json_list = [
      json_element(1),
      json_element(2),
      json_element(3)
    ]
    previous_state = {previous_json_list, 0}

    #When: Requesting more events than available, no pending demand
    {:noreply, events, {json_list, pending_demand}} = Producer.handle_demand(7, previous_state)

    # Then: Fire all events, store pending demand
    assert events == previous_json_list
    assert json_list == []
    assert pending_demand == (7 - 3)
  end

  test "pending demand => add to new demand" do
    # Given: Pending demand of 3
    previous_pending_demand = 3
    previous_json_list = [
      json_element(1),
      json_element(2),
      json_element(3),
      json_element(4),
      json_element(5)
    ]
    previous_state = {previous_json_list, previous_pending_demand}

    #When: Requesting events when pending demand
    new_demand = 1
    {:noreply, events, {json_list, pending_demand}} = Producer.handle_demand(new_demand, previous_state)

    # Then: Fire all events, store pending demand
    assert length(events)    == (previous_pending_demand + new_demand)
    assert length(json_list) == 1
    assert pending_demand    == 0
  end

  test "add new elements to the list, no pending demand" do
    # Given: 3 elements in the list
    previous_json_list = [
      json_element(1),
      json_element(2),
      json_element(3)
    ]
    previous_state = {previous_json_list, 0}

    # When: Add new elements, no pending demand
    new_elements = [json_element(4), json_element(5)]
    {:ok, {events, json_list, pending_demand}} = add_elements(new_elements, previous_state)

    # Then: new elements added, no events fired
    assert length(events) == 0
    assert json_list      == previous_json_list ++ new_elements
    assert pending_demand == 0
  end

  test "add new elements to the list, with pending demand" do
    # Given: Pending demand of 2
    previous_pending_demand = 2
    previous_json_list = [
      json_element(1),
      json_element(2),
      json_element(3)
    ]
    previous_state = {previous_json_list, previous_pending_demand}

    # When: Add new elements, exisiting pending demand
    new_elements = [json_element(4), json_element(5)]
    {:ok, {events, json_list, pending_demand}} = add_elements(new_elements, previous_state)

    # Then: elements are fired to fullfill pending demand, new elements are added
    assert events         == [json_element(1), json_element(2)]
    assert json_list      == [json_element(3), json_element(4), json_element(5)]
    assert pending_demand == 0
  end

  test "add new elements to the list, with pending demand, pending demand still too high to be fullfilled" do
    # Given: Pending demand of 30
    previous_pending_demand = 30
    previous_json_list = [
      json_element(1),
      json_element(2),
      json_element(3)
    ]
    previous_state = {previous_json_list, previous_pending_demand}

    # When: Add new elements, exisiting pending demand
    new_elements = [json_element(4), json_element(5)]
    {:ok, {events, json_list, pending_demand}} = add_elements(new_elements, previous_state)

    # Then: all elements are fired, pending demand is stored
    assert events         == previous_json_list ++ new_elements
    assert json_list      == []
    assert pending_demand == (30 - (length(previous_json_list) + length(new_elements)))
  end

  test "add new elements in invalid format, shutdown" do
    # Given: new elements in wrong format
    not_list = 234

    # When: add elements
    {:error, not_list_response} = add_elements(not_list, {[], 0})

    # Then: server stops
    assert {:stop, :shutdown, []} = not_list_response
  end

  def add_elements(new_elements, previous_state) do
    case Producer.handle_call({:add, new_elements}, nil, previous_state) do
      {:reply, :ok, events, {json_list, pending_demand}} ->
        {:ok, {events, json_list, pending_demand}}
      result ->
        {:error, result}
    end
  end

  def json_element(index) do
    "json" <> to_string(index)
  end

end
