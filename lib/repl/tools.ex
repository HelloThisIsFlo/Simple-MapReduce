defmodule Repl.Tools do
  alias SimpleMapreduce

  @bench 10_000
  @pipeline_name "bench"
  @number_workers 10

  def start_pipeline_with_workers do
    SimpleMapreduce.start_new_pipeline @pipeline_name
    for _ <- 1..@number_workers do
      SimpleMapreduce.add_worker @pipeline_name, node()
    end
  end

  # TODO: Fix

  # def benchdistrib(b \\ @bench) do
  # #    start_pipeline_with_workers()
  #   json = json_match() |> List.duplicate(b)
  #   IO.puts "--------------------------------------------------"
  #   IO.puts "Benchmarking Distributed Parsing with #{b} elements"
  #   measure(SimpleMapreduce, :parse_all, [json, @pipeline_name, :infinity])
  #   IO.puts "--------------------------------------------------"
  # end
  # def benchasync(b \\ @bench) do
  #   IO.puts "--------------------------------------------------"
  #   IO.puts "Benchmarking Async(local) Parsing with #{b} elements"
  #   json_without_id = match_string() |> List.duplicate(b)
  #   measure(Experimental.Parsing, :async_all, [json_without_id])
  #   IO.puts "--------------------------------------------------"
  # end
  # def compare(b \\ @bench) do
  #   IO.puts ""
  #   benchasync b
  #   benchdistrib b
  #   IO.puts ""
  # end

  # def json_element(index), do: {:football, :runningball, "json" <> to_string(index), index}
  # def json_match, do: {:football, :runningball, match_string(), 1234}
  # def match_string, do: "./runningball.json" |> File.read!

  def measure(module, function, args \\ []) when is_list(args) do
    duration = :timer.tc(module, function, args)
    |> elem(0)
    |> Kernel./(1_000_000)
    IO.inspect duration
  end
end
