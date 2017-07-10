# SimpleMapreduce

A simple distributed and load-balanced MapReduce.

It is fault tolerent, but does not guarantee that all events are parsed.

When a batch fail, the worker is immediately restarted and continue to accept new batches, but the failed batch is lost.
The same happen when a machine fail, the batch that was being parsed is lost.

## Initial setup
Implement the `SimpleMapreduce.HeavyWork` behavior, and provide it to the configuration file.
Also provide the names of the nodes: 

* `main_node` is where the pipeline is located, it should be the same on each machine. 
              It is used by the worker to know where is located the pipeline when connecting to it.

* `workers_node` is the default node where the workers are started.
                 Usually it is different on each node, and it is the name of the current node (`node()`).

A good practice is to put the node configuration in an external file `nodes.exs` and import it in the main config.
That allows to remove the `node.exs` from version control.
Which is useful since it is different on each machine

Finally set the max demand for each worker. (Check `GenStage.sync_subscribe` documentation for more details)

```
config :simple_mapreduce,
  heavy_work_module: MyApplication.MyHeavyWorkModule,
  max_demand_for_worker: 20

config :simple_mapreduce,
  main_node: :"main@MACHINE-NAME",
  workers_node: :"worker@MACHINE-NAME"

```

###Important
**After changing the configuration. Recompile the dependency**

## After initial setup

1. Start a pipeline by name:
  *  `SimpleMapreduce.start_new_pipeline(PIPELINE_NAME)`

2. Add workers on the main machine: 
  *  `SimpleMapreduce.add_worker(PIPELINE_NAME, NODE_WHERE_TO_SPAWN_WORKER)`
  * If NODE_WHERE_TO_SPAWN_WORKER is not provided, will use `:workers_node` from config
  * NODE_WHERE_TO_SPAWN_WORKER can be `node()`

3. Add **Extra** workers on all extra machines.
  *  `SimpleMapreduce.add_extra_worker(PIPELINE_NAME, NODE_WHERE_TO_SPAWN_WORKER)`
  * If NODE_WHERE_TO_SPAWN_WORKER is not provided, will use `:workers_node` from config
  * NODE_WHERE_TO_SPAWN_WORKER can be `node()`
  
4. Perform work super fast by passing a list to the pipeline.
  * `SimpleMapreduce.do_heavy_work_on_all_elements(ELEMENTS, PIPELINE_NAME, TIMEOUT)`
  * TIMEOUT
    * Can be :infinity
    * Default is 3000ms


