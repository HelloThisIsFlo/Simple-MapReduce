defmodule SimpleMapreduce.Mocks.ConfigTest do
  alias SimpleMapreduce.Mocks.Config
  use ExUnit.Case

  test "default node config for tests" do
    assert :"nonode@nohost" == Config.main_node()
    assert :"nonode@nohost" == Config.workers_node()
  end

  test "pipeline name" do
    assert :"SimpleMapreduce.Pipeline:name" == Config.pipeline_id("name")
  end

  test "max demand" do
    assert 2 == Config.max_demand()
  end

end
