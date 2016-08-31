---- xPatterns Spark Job Server Rest Dockerfile ----


# ---- Version control ----

FROM xpatterns/java:7u79

ENV VERSION 1

ENV XPATTERNS_SJR_VERSION 0.6.2
ENV XPATTERNS_INGESTION_VERSION 4.0.2
ENV XPATTERNS_SPARK_BRIDGE_VERSION 2.0.7

#ENV SPARK_XPATTERNS_VERSION 0.0.1

ENV SPARK_VERSION 1.6.0
ENV SCALA_VERSION 2.10.4

# ---- Default Environmental Variables ----

ENV SPARK_EXECUTOR_MEMORY 2g
ENV SPARK_CORES 2

ENV HADOOP_CONF_DIR /usr/local/hadoop-conf

ENV SPARK_HOME /usr/local/spark
ENV SJR_HOME /usr/local/spark-job-server

ENV SPARK_HOST spark-master.ydcloud.net
ENV SPARK_PORT 7077

ENV HADOOP_HOST xpatterns-hadoop
ENV HADOOP_PORT 8020

ENV HIVE_METASTORE_HOST xpatterns-hadoop
ENV HIVE_METASTORE_PORT 9083

ENV ZOOKEEPER_HOST xpatterns-hadoop

ENV REALM STAGING.XPATTERNS.COM
ENV KDC_SERVER 10.0.2.181
ENV USER schuszterc

# ---- Download Links ----

ENV SPARK_LINK https://s3.amazonaws.com/xpatterns/dependencies/spark/spark-${SPARK_VERSION}-bin-xpatterns-spark-secure.tar.gz

#ENV XPATTERNS_SJR_DOWNLOAD_LINK https://github.com/Atigeo/spark-job-rest/releases/download/${XPATTERNS_SJR_VERSION}-spark1.3.1/spark-job-rest.tar.gz


# ---- Ports ----

EXPOSE 8998


# ---- apt-get install ----

RUN apt-get update && apt-get install -y \
	s3cmd \
	wget \
	curl \
	maven \
        at

COPY conf/s3cfg /tmp/s3cfg


# ---- Install Livy ----


RUN mvn -DskipTests -Dspark.version=${SPARK_VERSION} clean package
RUN s3cmd -c /tmp/s3cfg --no-progress get s3://${XPATTERNS_SJR_DOWNLOAD_LINK} /tmp/

#RUN wget ${XPATTERNS_SJR_DOWNLOAD_LINK} -O /tmp/spark-job-rest.tar.gz

RUN mkdir -p ${SJR_HOME}
RUN tar xzf /tmp/${XPATTERNS_SJR_TAR} -C /usr/local/spark-job-server/
COPY conf/settings.sh ${SJR_HOME}/
#COPY conf/server_start.sh ${SJR_HOME}/
#RUN chmod +x ${SJR_HOME}/server_start.sh
#COPY conf/manager_start.sh ${SJR_HOME}/
#RUN chmod +x ${SJR_HOME}/manager_start.sh
RUN mkdir /usr/local/xpatterns/


# ---- Spark ----

# Copy Spark
RUN wget ${SPARK_LINK} -P /tmp/
RUN tar xzf /tmp/spark-${SPARK_VERSION}-bin-xpatterns-spark-secure.tar.gz -C /tmp/
RUN rm -Rf /tmp/*.tar.gz
RUN mv /tmp/spark* /usr/local/spark

RUN mkdir /var/log/sjr/
RUN mkdir /jars/

# ---- Copy Hadoop configuration ---

RUN mkdir -p /usr/local/hadoop-conf
COPY docker-deps/core-site.xml /usr/local/hadoop-conf/
COPY docker-deps/hdfs-site.xml /usr/local/hadoop-conf/
COPY docker-deps/yarn-site.xml /usr/local/hadoop-conf/

# ---- Clear tmp dir ----

COPY docker-deps/cristians.keytab /tmp/
#RUN rm -Rf /tmp/*

# ---- Mounting Volume ----
VOLUME /usr/local/workflow

# ---- Setup the startup script ----

COPY conf/run.sh /usr/bin/run.sh
RUN chmod u+x /usr/bin/run.sh
CMD ["/usr/bin/run.sh"]