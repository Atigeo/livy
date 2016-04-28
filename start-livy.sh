env \
  LIVY_SERVER_JAVA_OPTS="-Dlivy.server.session.factory=yarn -Djava.security.krb5.realm=STAGING.XPATTERNS.COM -Djava.security.krb5.kdc=10.0.2.181" \
  ./bin/livy-server
