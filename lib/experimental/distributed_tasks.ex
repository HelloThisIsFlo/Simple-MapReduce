defmodule Experimental.DistributedTasks do
  require Logger

  @heavy_work_module Repl.FakeHeavyWork


  def num_nodes, do: 2
  def get_node(1),   do: :"main@iopo0546"
  def get_node(0),   do: :"other@iopo0546"
  def get_node(_),   do: node()


  def async(elements) when is_list(elements) do
    Logger.info "Performing async_stream"
    Experimental.HeavyWorkTasks
    |> Task.Supervisor.async_stream(elements, @heavy_work_module, :do_heavy_work, [])
    |> Enum.to_list
    |> Enum.map(&extract_result/1)
  end

  def distributed(elements) when is_list(elements) do
    elements
    |> split(num_nodes())
    |> Enum.with_index
    |> Enum.map(fn({sub_list_elements, idx}) ->
      Task.Supervisor.async({Experimental.RoutingTasks, get_node(idx)}, fn -> async(sub_list_elements) end)
    end)
    |> Enum.map(&Task.await(&1, 600_000))
    |> List.flatten
  end

  def split(list, num_chunks) do
    len = round(length(list) / num_chunks)
    Enum.chunk(list, len, len, [])
  end


  defp extract_result({:ok, result}), do: result
  defp extract_result(_), do: raise ArgumentError, "Idk what happened"


end
