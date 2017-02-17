defmodule SimpleMapreduce.HeavyWork do
  @callback do_heavy_work(any) :: any
end
