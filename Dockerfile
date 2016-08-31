# ---- xPatterns Livy Rest Dockerfile ---------

FROM xpatterns/java:7u79

ENV SPARK_VERSION 1.6.0
ENV SCALA_VERSION 2.10.4

# ---- Default Environmental Variables ----

ENV SPARK_EXECUTOR_MEMORY 2g
ENV SPARK_CORES 2

ENV LIVY_HOME /usr/local/livy

ENV SPARK_HOME /usr/local/spark
ENV HADOOP_CONF_DIR /usr/local/hadoop-conf

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

ENV XPATTERNS_SPARK_LINK xpatterns/dependencies/spark/spark-${SPARK_VERSION}-bin-xpatterns-spark-secure.tar.gz
ENV XPATTERNS_LIVY_DOWNLOAD_LINK xpatterns/livy/0.3.0/livy-server-0.3.0-SNAPSHOT.tar.gz

# ---- Ports ----

EXPOSE 8998

# ---- apt-get install ----

RUN apt-get update && apt-get install -y s3cmd

RUN mkdir -p /tmp/
COPY conf/s3cfg /tmp/s3cfg

# ---- Install Livy ----

RUN s3cmd -c /tmp/s3cfg --no-progress get s3://${XPATTERNS_LIVY_DOWNLOAD_LINK} /tmp/
RUN tar xzf /tmp/livy-server-0.2.0-SNAPSHOT.tar.gz -C /usr/local/
RUN rm -Rf /tmp/*.tar.gz
RUN mv /usr/local/livy-server-0.2.0-SNAPSHOT /usr/local/livy

COPY conf/livy-defaults.conf ${LIVY_HOME}/conf/
COPY conf/core-site.xml ${HADOOP_CONF_DIR}/
COPY conf/hdfs-site.xml ${HADOOP_CONF_DIR}/

# ---- Spark ----

# Copy Spark

RUN s3cmd -c /tmp/s3cfg --no-progress get s3://${XPATTERNS_SPARK_LINK} /tmp/
RUN tar xzf /tmp/spark-${SPARK_VERSION}-bin-xpatterns-spark-secure.tar.gz -C /tmp/

RUN rm -Rf /tmp/*.tar.gz
RUN mv /tmp/spark* /usr/local/spark

RUN mkdir /var/log/sjr/
RUN mkdir /jars/

# ---- Setup run config ----
ENV LIVY_SERVER_JAVA_OPTS="-Dlivy.server.session.factory=yarn -Djava.security.krb5.realm=STAGING.XPATTERNS.COM -Djava.security.krb5.kdc=10.0.2.181"

COPY conf/cristians.keytab /usr/local/livy/
CMD ["/usr/local/livy/bin/livy-server"]

