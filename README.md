# docker-jupyter-spark2
Work sponsored by [Archethought](https://archethought.github.io/)

I could not find a dockerized jupyter notebook with Spark 2, 
so I merged Docker Stacks [pyspark-notebook](https://github.com/jupyter/docker-stacks/tree/master/pyspark-notebook) 
and [all-spark-notebook](https://github.com/jupyter/docker-stacks/tree/master/all-spark-notebook) with an update to Spark 2.0.2

# Proof of Concept - Read from MySQL Database
This branch will _not_ be merged into master.
It is a test to establish MySQL access through a docker container jupyter notebook, and is also detailed documentation for Stack Overflow question [41688251](http://stackoverflow.com/questions/41688251/jupyter-spark-database-access-java-lang-classnotfoundexception-com-mysql-jdbc).

## Setup Steps

### Names
Go ahead and define what to name the parts.
```
export DB_NOTEBOOK_IMAGE="mysql-notebook-image"
export DB_NOTEBOOK_CONTAINER="mysql-notebook"
export MYSQL_SERVER_CONTAINER="mysql-db"
export MYSQL_ROOT_PASSWORD="datascience" 
export DB_DOCKER_NETWORK="dbnet"
```

### Networking
Create a separate network for database containers, or just use the default docker bridge network, "bridge".
Containers must be in the same network to communicate.
```
docker network create --driver bridge $DB_DOCKER_NETWORK
```
###  Build Notebook Image & Container
Commands used to create the image & container for this notebook
```
# create image
time docker build -t $DB_NOTEBOOK_IMAGE . 1>build.log 2>build.err  ;ll
 
# create container
docker run -d -p 8826:8888  -e GRANT_SUDO=yes --user root --net=$DB_DOCKER_NETWORK --name=$DB_NOTEBOOK_CONTAINER --link $MYSQL_SERVER_CONTAINER:$DB_NOTEBOOK_CONTAINER  $DB_NOTEBOOK_IMAGE  start-notebook.sh
```
You can use any port you like to access the container; i.e., `docker run -d -p 8877:8888  --name=spark2 spark2-image`  
Issue the command `docker ps` to ensure your container is running. 
Then, open in your browser url `<IP address of machine running docker>:8888/home`, and upload or create your jupyter notebook!

#### Clean up
```
# clean up image & container when no longer needed
 docker stop $DB_NOTEBOOK_CONTAINER ;docker rm $DB_NOTEBOOK_CONTAINER ;docker rmi $DB_NOTEBOOK_IMAGE
```
 
### Database Server

```
docker run --detach --name=$MYSQL_SERVER_CONTAINER --net=$DB_DOCKER_NETWORK --env="MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" -p 6603:3306 mysql
```

This will use the [official mysql docker image](https://hub.docker.com/_/mysql/) to create a database server container with root password $MYSQL_ROOT_PASSWORD (defined above).
Capture the IP address of the DB server container with `docker inspect mysql-db | grep -i 'ipaddress'`
This will yeild something like
```
            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAddress": "172.18.0.4",
```

### Command Line Client
To create a database and add data, access the mySql server through a command line by creating another mysql container linked to the server container. 
This container will only exist until you exit the mysql command prompt. 
Assume the data you want to load into the database is in `/home/cownby/data/` on the host system.
Of course, modify for your environment.
(Note no shell variable substitution inside single quotes.)
```
docker run -it -v "/home/cownby/data/":"/data" --net=$DB_DOCKER_NETWORK --link "$MYSQL_SERVER_CONTAINER":mysql --rm mysql sh -c 'exec mysql -h172.18.0.4 -uroot -p'

```
You will be prompted for the password, $MYSQL_ROOT_PASSWORD

### Sample SQL Commands

```SQL
/*  
Assume volume is mounted to `/data` and data is in file `supers.csv`.

sample data:
id,firstName,lastName,superpower,goodDeeds,maxSpeed
0,100,carolyn,ownby,smile,72,15.5
0,200,krizia,conrad,good food!,80,25.7
0,300,jordan,dick,roadster,30,80.25
0,400,dixon,dick,vision,65,56.8

*/

create database giskard;
use giskard;
create table supers (
	key_id      int NOT NULL AUTO_INCREMENT UNIQUE,
	import_id   int,
	first_name  varchar(20),
	last_name   varchar(20),
	super_power varchar(20),
	good_deeds  int,
	max_speed   float
);

load data local infile '/data/supers.csv'
      into table supers
      fields terminated by ','
      lines terminated by '\n'
      ignore 1 rows;
```


## References

* [Excel to MySQL](http://www.prcconsulting.net/2016/10/migrating-an-excel-spreadsheet-to-mysql-and-to-spark-2-0-1-part-1/)  
This is NOT done programmatically, but by simply exporting an excel sheet as csv and importing into mySQL.
* [Spark & MySQL](http://www.prcconsulting.net/wp-content/uploads/2016/10/Connect_MySQL.py_-1.html)
* [Spark & database properties](http://spark.apache.org/docs/latest/sql-programming-guide.html#jdbc-to-other-databases)
* [tutorial](http://severalnines.com/blog/mysql-docker-containers-understanding-basics)
* [official mysql docker repository](https://hub.docker.com/_/mysql/)
 
## Notes
* To get inside container, use `docker exec -it spark202 /bin/bash`
* inside the  container, jar files are under 
  * /opt/conda/lib/python3.5/site-packages/toree/lib/
  * /opt/conda/envs/python2/share/py4j/
  * /home/jovyan/.local/share/jupyter/kernels/apache_toree_scala/lib/
  * /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/
  * /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/ext/
  * /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/
  * /usr/share/maven-repo/mysql/mysql-connector-java/5.1.39/
  * /usr/share/java/
  * /usr/share/ca-certificates-java/
  * /usr/share/texlive/texmf-dist/scripts/
  * /usr/local/spark-2.0.2-bin-hadoop2.7/jars/
  * /usr/local/spark-2.0.2-bin-hadoop2.7/examples/jars/
  * /usr/local/spark-2.0.2-bin-hadoop2.7/yarn/
  

