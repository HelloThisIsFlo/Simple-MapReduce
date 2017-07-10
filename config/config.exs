use Mix.Config

config :simple_mapreduce,
  heavy_work_module: Repl.FakeHeavyWork,
  max_demand_for_worker: 20

config :simple_mapreduce,
  main_node: :"main@iopo0546",
  workers_node: :"worker@iopo0546"

# Import node config as a separated file
# Override node configuration in `nodes.exs` file
#import_config "nodes.exs"

# Override all config (node included) with env specific configs
import_config "#{Mix.env}.exs"
