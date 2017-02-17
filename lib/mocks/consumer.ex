defmodule SimpleMapreduce.Mocks.Consumer do
  use GenStage

  def start_mock_and_subscribe do
    # Self is the process who called this method (test process)
    GenStage.start_link(__MODULE__, self())
  end

  def init(test_pid) do
    {:consumer, test_pid}
  end

  def handle_events(events, from, test_pid) do
    # Forward the events to the test process
    send test_pid, {:handle_events, events, from}
    {:noreply, [], test_pid}
  end


end
