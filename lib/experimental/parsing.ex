# TODO: Fix

# defmodule Experimental.Parsing do
#   # alias SimpleMapreduce.RoutingTasks
#   alias ScoresReborn.Parsing
#   require Logger


#   def num_nodes, do: 1
#   def get_node(1),   do: :"foo@shockn745-linux-desktop"
#   def get_node(0),   do: :"foo@shockn745-linux-desktop"

#   def get_node(_),   do: node()


#   def local(all_json, sport, provider) when is_list(all_json) do
#     all_json
#     |> Enum.map(&Parsing.parse!(1, &1, sport, provider))
#   end


#   # Parse all with fake id
#   def async_all(json_list) do
#     json_list
#     |> Task.async_stream(&parse_mock/1, [])
#     |> Enum.to_list
#     |> Enum.map(&extract_result/1)
#   end

#   def parse_mock(json) do
#     Parsing.parse!(1234, json, :football, :runningball)
#   end

#   # def async(json_list, sport, provider) when is_list(json_list) do
#   #   Logger.info "Parsing async_stream"
#   #   SimpleMapreduce.ParsingTasks
#   #   |> Task.Supervisor.async_stream(json_list, Parsing, :parse!, [sport, provider])
#   #   |> Enum.to_list
#   #   |> Enum.map(&extract_result/1)
#   # end


#   # def distributed(all_json, sport, provider) when is_list(all_json) do
#   #   all_json
#   #   |> split(num_nodes())
#   #   |> Enum.with_index
#   #   |> Enum.map(fn({json_list, idx}) ->
#   #     Task.Supervisor.async({RoutingTasks, get_node(idx)}, SimpleMapreduce.Parsing, :async, [json_list, sport, provider])
#   #   end)
#   #   |> Enum.map(&Task.await(&1, 600_000))
#   #   |> List.flatten
#   # end



#   def split(list, num_chunks) do
#     len = round(length(list) / num_chunks)
#     Enum.chunk(list, len, len, [])
#   end

#   def parse_with_logs(id, json, sport, provider) do
#     Logger.info "Parsing json"
#     Parsing.parse!(id, json, sport, provider)
#   end












#   defp extract_result({:ok, result}), do: result
#   defp extract_result(_), do: raise ArgumentError, "Idk what happened"


# end
