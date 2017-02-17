defmodule SimpleMapreduce.Mocks.HeavyWork do
  use GenServer
  require Logger
  @behaviour SimpleMapreduce.HeavyWork

  def start_mock_and_subscribe do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
    GenServer.call(__MODULE__, {:subscribe, self()})
  end

  def do_heavy_work(text) do
    crash? = GenServer.call(__MODULE__, {:work, text})
    case crash? do
      false ->
        {:ok, text <> " <== PROCESSED"}
      :infinite ->
        simulate_crash()
      n when is_number(n) ->
        simulate_crash()
    end
  end

  defp simulate_crash do
    Logger.warn "Simulated crash !!!!, on #{inspect self()}"
    raise "Simulated Crash !!"
  end

  def activate_crash_on_work(number_of_crash \\ :infinite) do
    GenServer.call(__MODULE__, {:crash_on_work, number_of_crash})
  end
  def deactivate_crash_on_work do
    GenServer.call(__MODULE__, {:crash_on_work, false})
  end

  ############################
  ###  GenServer callbacks ###
  ############################
  def init(:ok) do
    {:ok, %{subscribers: [], crash: false}}
  end

  def handle_call({:subscribe, pid}, _from, %{subscribers: subscribers} = state) do
    subscribers = [pid | subscribers]
    {:reply, :ok, %{state | subscribers: subscribers}}
  end

  def handle_call({:work, arg}, _from, %{subscribers: subscribers, crash: crash} = state) do
    for sub <- subscribers do
      send sub, {:work, arg}
    end
    crash = decrement_crash(crash)
    {:reply, crash, %{state | crash: crash}}
  end
  def handle_call({:crash_on_work, crash}, _from, state) do
    {:reply, :ok, %{state | crash: crash}}
  end

  defp decrement_crash(:false), do: :false
  defp decrement_crash(0), do: false
  defp decrement_crash(crash) when is_number(crash), do: (crash - 1)
  defp decrement_crash(:infinite), do: :infinite



end
