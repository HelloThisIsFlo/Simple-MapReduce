defmodule Repl.Tools do
  alias SimpleMapreduce

  @bench 10_000
  @pipeline_name "bench"
  @number_workers 10
  @heavy_work_module Repl.FakeHeavyWork


  def start_pipeline_with_workers do
    SimpleMapreduce.start_new_pipeline @pipeline_name
    for _ <- 1..@number_workers do
      SimpleMapreduce.add_worker @pipeline_name, node()
    end
  end


  def benchdistrib(b \\ @bench) do
     start_pipeline_with_workers()
    elements = "text" |> List.duplicate(b)
    IO.puts "--------------------------------------------------"
    IO.puts "Benchmarking Distributed Parsing with #{b} elements"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    measure(Repl.Tools, :distributed, [elements])
    IO.puts "--------------------------------------------------"
  end
  def benchasync(b \\ @bench) do
    IO.puts "--------------------------------------------------"
    IO.puts "Benchmarking Async(local) Parsing with #{b} elements"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    IO.puts "WARNING ==> Benchmark is broken, remove RANDOM sleep from FakeHeavyWork"
    elements = "text" |> List.duplicate(b)
    measure(Repl.Tools, :async, [elements])
    IO.puts "--------------------------------------------------"
  end


  def distributed(elements) do
    SimpleMapreduce.do_heavy_work_on_all_elements(elements, @pipeline_name, :infinity)
  end
  def async(elements) do
    elements
    |> Task.async_stream(&@heavy_work_module.do_heavy_work/1, [])
    |> Enum.to_list
    |> Enum.map(&extract_result/1)
  end
  defp extract_result({:ok, result}), do: result
  defp extract_result(_), do: raise ArgumentError, "Idk what happened"


  def compare(b \\ @bench) do
    IO.puts ""
    benchasync b
    benchdistrib b
    IO.puts ""
  end


  def measure(module, function, args \\ []) when is_list(args) do
    duration = :timer.tc(module, function, args)
    |> elem(0)
    |> Kernel./(1_000_000)
    IO.inspect duration
  end

  def list(length \\ 10) do
    1..length
    |> Enum.to_list
    |> Enum.map(&to_string/1)
  end
end
