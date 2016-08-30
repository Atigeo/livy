Instructions
============

See instructions in README.rst to get started.  These instructions are specific to the Atigeo branch.


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

You'll need to ask devops for proper instructions on deploying it.

Configure: Livy.conf
-------------------
You will likely need to change everything in livy.conf.

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

One way to 

The version of livy that is currently deployed is 0.2.0.  These instructions
are for deploying 0.3.0.  To pick up this new version, edit Dockerfile in spatterns-livy-docker.
The path is in XPATTERNS_LIVY_DOWNLOAD_LINK.
Adjust the version numbers there to deploy 0.3.0.


    $ cd assembly/target/
    $ unzip livy-server-0.3.0-SNAPSHOT.zip
    $ tar cvfz livy-server-0.3.0-SNAPSHOT.tar.gz livy-server-0.3.0-SNAPSHOT
    $ rm -rf livy-server-0.3.0-SNAPSHOT
    $ s3cmd put livy-server-0.3.0-SNAPSHOT.tar.gz s3://xpatterns/livy/0.3.0/livy-server-0.3.0-SNAPSHOT.tar.gz
    
You need to set up an appropriate s3 configuration file for s3cmd, containing
the access key and secret key for S3.  These instructions assume that you have an
AWS account with write priviliges, and that you have specified the access key in 
```$HOME/.s3cfg```.



