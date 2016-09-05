# docker-jupyter-spark2
Work sponsored by Archethought, http://www.archethought.com/

I could not find a dockerized jupyter notebook with Spark 2, 
so I merged Docker Stacks [pyspark-notebook](https://github.com/jupyter/docker-stacks/tree/master/pyspark-notebook) 
and [all-spark-notebook](https://github.com/jupyter/docker-stacks/tree/master/all-spark-notebook) with an update to Spark 2.0.0
 
 Build image with 
 ```
 $ docker build -t "all-spark-2:dockerfile" <path to dockerfile>
 ```
