## docker-jupyter-spark2
Work sponsored by [Archethought](https://archethought.github.io/)

I could not find a dockerized jupyter notebook with Spark 2, 
so I merged Docker Stacks [pyspark-notebook](https://github.com/jupyter/docker-stacks/tree/master/pyspark-notebook) 
and [all-spark-notebook](https://github.com/jupyter/docker-stacks/tree/master/all-spark-notebook) with an update to Spark 2.0.2
 

Build suggestion:  
```
date; docker build -t spark2-image . 1>build.log 2>build.err ;date ;ll 

```
Build.err will be empty if the image built successfully.
Issue the command `docker images` to ensure the image you specified above was created. 

Run suggestion:
```
docker run -d -p 8888:8888  -e GRANT_SUDO=yes --user root --name=spark2 spark2-image start-notebook.sh 

```
You can use any port you like to access the container; i.e., `docker run -d -p 8877:8888  --name=spark2 spark2-image`  
Issue the command `docker ps` to ensure your container is running. 
Then, open in your browser url `<IP address of machine running docker>:8888/home`, and upload or create your jupyter notebook!
 
### Clean up
```
docker stop spark2
docker rm spark2
docker rmi spark2-image
```
 
### Notes
* inside the  container, jar files are under /usr/local/spark-2.0.0-bin-hadoop2.7/jars
* To get inside container, use `docker exec -it spark202 /bin/bash`

