# docker-jupyter-spark2
Work sponsored by Archethought, http://www.archethought.com/

I could not find a dockerized jupyter notebook with Spark 2, 
so I merged Docker Stacks [pyspark-notebook](https://github.com/jupyter/docker-stacks/tree/master/pyspark-notebook) 
and [all-spark-notebook](https://github.com/jupyter/docker-stacks/tree/master/all-spark-notebook) with an update to Spark 2.0.0
 
 Example for building the image:
 ```
 $ docker build -t "jupyter-spark2-image" <path to dockerfile>
 ```
 Issue the command `docker images` to ensure the image you specified above built. 
 Now you want to create and run a container with the image.
 Example:
 ```
docker run -d -p 8888:8888  --name=spark2 jupyter-spark2-image
 ```
 
 Issue the command `docker ps` to ensure your container is running. 
 Then, open in your browser url `<IP address of machine running docker>:8888/home`
 
 You can use any port you like to access the container; i.e., `docker run -d -p 8877:8888  --name=spark2 jupyter-spark2-image`
 
## Notes

### Container modifications

These are additions I've made to my container which may or may not be propagated to the image definition/Dockerfile, but am recording for tracking purposes.
Added to /usr/local/spark/conf:

 * core-site.xml
 * hdfs-site.xml
 * spark-env.xml, added HADOOP_CONF_DIR=$SPARK_HOME/conf
