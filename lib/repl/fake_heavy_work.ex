defmodule Repl.FakeHeavyWork do
  require Logger
  @behaviour SimpleMapreduce.HeavyWork

  # TODO: Remove random component (doesn't make sense for a benchmark)
  #       But generate random time based on a hash of the node name.
  #       ==> Constant for bench, but different on each node.

  def do_heavy_work(to_process) do
    random = Enum.random 1..10000
    Logger.info "Doing heavy work for #{random} ms"
    Process.sleep random
    to_process <> " <== PROCESSED"
  end
end
