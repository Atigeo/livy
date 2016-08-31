Instructions
============

See instructions in README.rst to get started. 
These instructions are specific to the Atigeo branch.

Overview
--------
Livy is a spark job server with a REST interface.  Livy creates and owns the SparkContext, and
impersonates a specific user.  Python code to execute is submitted in string form to
Livy, which interprets it in its own process, where it has access to the SparkContext.

Livy itself is in a different project in github (https://github.com/Atigeo/livy.git).  That project builds a zip, which is stored
in S3.  This project picks up that file and builds a docker.  It does not contain the Livy code
itself.  See instructions.md in that project for instructions on how to build the zip file, and how to
test locally with Livy.

Build
-----
To build, cd to livy and:

    $ mvn -DskipTests -Dspark.version=1.6.0 clean package




Local Setup
-----------

Some settings are not default to livy, those were the main additions in the project, the reason why we forked it.
Some changes were done to the "ContextLauncher" class and to the "InteractiveSession", mostly for addapting configs.

You need to have a local spark download, at least.
We are running spark 1.6.0 as of now.
Download spark from the web and extract it somewhere locally. Make livy conf point to it.

The way it is deployed is by adding all of the files in assembly in a zip file which is then posted to S3.
Then a project ```xpatterns-livy-docker``` builds a docker, pulling livy from S3.

The docker is deployed in production using the normal process with xpatterns-docker-compose.

Configure: Livy.conf
-------------------
You will likely need to change everything in livy.conf.
Many of these are overridden by configurations given at docker build time, so these
are only used as defaults.

The IP address where we are running

    livy.local.server.address=10.3.22.22

The hostname where we are running

    livy.spark.master.name=local


Livy needs to be used with yarn

    livy.server.session.factory = yarn

I guess this is the pythonpath for running the master and slave.
Do these have to be set when running n production?

    livy.spark.yarn.driver.pythonpath=/Users/chris/Virtualenvs/xpatterns-venv/bin/python
    livy.spark.yarn.slave.pythonpath=/Users/chris/Virtualenvs/xpatterns-venv/bin/python

If you are running spark R

    livy.sparkr.package =${SPARK_HOME}/R/lib/sparkr.zip#sparkr

Use impersonation (requires kerberos)

    livy.impersonation.enabled = true
    
Build and Copy to S3
--------------------
These instructions were derived from reverse engineering the existing code and 
deployed instances, and may be vague or inaccurate.

As stated above, livy is build locally, then copied to S3.  The top level pom includes 
a version, currently 0.3.0-SNAPSHOT.  When the project is build with maven, it creates 
a file assembly/target/livy-server-3.0-SNAPSHOT.zip.  This needs to be converted to tar.gz 
and copied to S3.

    $ cd assembly/target/
    $ unzip livy-server-0.3.0-SNAPSHOT.zip
    $ tar cfz livy-server-0.3.0-SNAPSHOT.tar.gz livy-server-0.3.0-SNAPSHOT
    $ rm -rf livy-server-0.3.0-SNAPSHOT
    $ s3cmd put livy-server-0.3.0-SNAPSHOT.tar.gz s3://xpatterns/livy/0.3.0/livy-server-0.3.0-SNAPSHOT.tar.gz
    
You need to set up an appropriate s3 configuration file for s3cmd, containing
the access key and secret key for S3.  These instructions assume that you have an
AWS account with write priviliges, and that you have specified the access key in 
```$HOME/.s3cfg```.


Unified Project Structure
=========================
Currently, the docker is built using a separate project: xpatterns-livy-docker.  
This extra step is unnecessarily complicated.  The docker could instead be built with the docker
present here.  

Docker Build
------------
    $ docker build .

Jenkins Docker Build
--------------------
The code in Jenkins to build the docker is shown below.

```
BUILD_NAME=xpatterns-livy

docker build --no-cache -t $DOCKER_REGISTRY/$BUILD_NAME:${RELEASE_VERSION} .
docker tag -f $DOCKER_REGISTRY/$BUILD_NAME:${RELEASE_VERSION} $DOCKER_REGISTRY/$BUILD_NAME:$branch_name

docker push $DOCKER_REGISTRY/$BUILD_NAME:${RELEASE_VERSION}
docker push $DOCKER_REGISTRY/$BUILD_NAME:$branch_name

git tag ${RELEASE_VERSION} 
git push origin ${RELEASE_VERSION}
```

Additional Changes
------------------
When the projects are unified, the following additional changes need to be made.
1.  The save and fetch through S3 should be eliminated.  Maven should build the
assembly, and then the docker build should use that.
2.  Maven should either build a tar.gz, or the docker should unpack from a zip, so that the conversion
step from zip to tar.gz is eliminated.
3.  The project should be moved from github to atigeo internal gitlab.
4.  Jenkins should be modified to look at the new gitlab repo, and to build the library then the
docker.

