Instructions
============

See instructions in README.md to get started.  These instructions are specific to the Atigeo branch.


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

The way it is deployed is by adding all of the files in assembly in a tar.gz file which is then posted to S3.
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

Docker
======

The code here also includes the ability to build and run in a docker.
There are various configurable items in the Docker, including kerberos information, 
that must be changed.

In Dockerfile, it appears that there is no conf/s3cfg.  Where would this come from?
