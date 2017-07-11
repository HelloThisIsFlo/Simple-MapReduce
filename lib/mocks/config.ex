defmodule SimpleMapreduce.Mocks.Config do
  alias SimpleMapreduce.Pipeline.Config

  @moduledoc """
  Same as Config, with some overridable parameters
  """

  def main_node,         do: Config.main_node()
  def workers_node,      do: Config.workers_node()
  def heavy_work_module, do: Config.heavy_work_module()
  def max_demand,        do: Config.max_demand()

  def pipeline_id(pipeline_name),      do: Config.pipeline_id(pipeline_name)
  def producer_id(pipeline_name),      do: Config.producer_id(pipeline_name)
  def anchor_id(pipeline_name),        do: Config.anchor_id(pipeline_name)
  def workerfactory_id(pipeline_name), do: Config.workerfactory_id(pipeline_name)
end
