defmodule SimpleMapreduce.Mocks.HeavyWorkTest do
  alias SimpleMapreduce.Mocks
  use ExUnit.Case

  @moduletag :capture_log

  setup do
    Mocks.HeavyWork.start_mock_and_subscribe
  end

  test "parse sends notification to subscriber" do
    # Given: subscribed to mock (see setup)
    # When: Calling Parse
    Mocks.HeavyWork.do_heavy_work("json1")

    # Then: Notification is received
    assert_receive {:work, "json1"}
  end

  test "crash on demand" do
    # Given: crash mode activated
    Mocks.HeavyWork.activate_crash_on_work

    # Then: Error raised on parsing, every time
    assert_raise RuntimeError, "Simulated Crash !!", fn ->
      Mocks.HeavyWork.do_heavy_work("json1")
    end
    assert_raise RuntimeError, "Simulated Crash !!", fn ->
      Mocks.HeavyWork.do_heavy_work("json1")
    end
    assert_raise RuntimeError, "Simulated Crash !!", fn ->
      Mocks.HeavyWork.do_heavy_work("json1")
    end
  end

  test "crash on demand - only a certain number of times" do
    # Given: crash mode activated
    Mocks.HeavyWork.activate_crash_on_work 2

    # Then: Crash 2 times, but ok 3rd
    assert_raise RuntimeError, "Simulated Crash !!", fn ->
      Mocks.HeavyWork.do_heavy_work("json1")
    end
    assert_raise RuntimeError, "Simulated Crash !!", fn ->
      Mocks.HeavyWork.do_heavy_work("json1")
    end

    # No crash on 3rd call
    Mocks.HeavyWork.do_heavy_work("json1")
  end

end
