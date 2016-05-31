#!/usr/bin/env bash
env \
  LIVY_SERVER_JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005 -Djava.security.krb5.realm=STAGING.XPATTERNS.COM -Djava.security.krb5.kdc=10.0.2.122" \
  ./bin/livy-server
