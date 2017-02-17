defmodule SimpleMapreduce.Pipeline.Config do

  def main_node,         do: fetch :main_node
  def workers_node,      do: fetch :workers_node
  def heavy_work_module, do: fetch :heavy_work_module
  def max_demand,        do: fetch :max_demand_for_worker

  @base_name "SimpleMapreduce.Pipeline"

  def pipeline_id(pipeline_name),      do: (@base_name <> ":" <> pipeline_name)
                                            |> String.to_atom
  def producer_id(pipeline_name),      do: (@base_name <> ".Producer:" <> pipeline_name)
                                            |> String.to_atom
  def anchor_id(pipeline_name),        do: (@base_name <> ".Anchor:" <> pipeline_name)
                                            |> String.to_atom
  def workerfactory_id(pipeline_name), do: (@base_name <> ".WorkerFactory:" <> pipeline_name)
                                            |> String.to_atom

  defp fetch(config_var), do: Application.fetch_env!(:simple_mapreduce, config_var)
end
