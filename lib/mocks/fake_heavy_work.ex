defmodule SimpleMapreduce.Mocks.FakeHeavyWork do
  require Logger
  @behaviour SimpleMapreduce.HeavyWork

  def do_heavy_work(_to_process) do
    Logger.info "Doing heavy work for 1 sec"
    Process.sleep 1000
  end
end
