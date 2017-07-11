use Mix.Config

# Override node configuration for local tests
config :simple_mapreduce,
  config_module: SimpleMapreduce.Mocks.Config,
  main_node:    :"nonode@nohost",
  workers_node: :"nonode@nohost"

# Use mock instead of parsing module
config :simple_mapreduce,
  heavy_work_module: SimpleMapreduce.Mocks.HeavyWork,
  max_demand_for_worker: 2
