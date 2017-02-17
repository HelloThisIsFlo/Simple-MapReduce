# SimpleMapreduce

A simple distributed and load-balanced MapReduce.

It is fault tolerent, but does not guarantee that all events are parsed.

When a batch fail, the worker is immediately restarted and continue to accept new batches, but the failed batch is lost.
The same happen when a machine fail, the batch that was being parsed is lost.

###### Initial setup
Implement the `SimpleMapreduce.HeavyWork` behavior, and provide it to the configuration file.
Also provide a `nodes.exs` configuration file (put in ./config/) with the names of the nodes: 

```
config :simple_mapreduce,
  main_node: :"main@main_machine",
  workers_node: :"worker@main_machine"
```

* `main_node` is where the pipeline is located, it should be the same on each machine. 
              It is used by the worker to know where is located the pipeline when connecting to it.

* `workers_node` is the default node where the workers are started.
                 Usually it is different on each node, and it is the name of the current node (self()).


###### After initial setup

1. Start a pipeline by name.
2. Add workers on the main machine.
3. Add extra workers on all extra machines.
4. Perform work super fast by passing a list to the pipeline.


