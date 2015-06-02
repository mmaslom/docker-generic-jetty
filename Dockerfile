FROM oberthur/docker-busybox-java:jdk8_8.45.14

MAINTAINER Dawid Malinowski <d.malinowski@oberthur.com>

ENV HOME=/opt/app
ENV JETTY_VERSION_MAJOR 9
ENV JETTY_VERSION_MINOR 9.1.5
ENV JETTY_VERSION_BUILD v20140505
ENV MARIADB_VERSION 1.1.8
WORKDIR /opt/app

RUN opkg-install bash

# Add user app
RUN echo "app:x:999:999::/opt/app:/bin/false" >> /etc/passwd; \
    echo "app:x:999:" >> /etc/group; \
    mkdir -p /opt/app; chown app:app /opt/app

# Install Jetty 9
RUN curl -L -O http://archive.eclipse.org/jetty/${JETTY_VERSION_MINOR}.${JETTY_VERSION_BUILD}/dist/jetty-distribution-${JETTY_VERSION_MINOR}.${JETTY_VERSION_BUILD}.tar.gz \
    && echo http://archive.eclipse.org/jetty/${JETTY_VERSION_MINOR}.${JETTY_VERSION_BUILD}/dist/jetty-distribution-${JETTY_VERSION_MINOR}.${JETTY_VERSION_BUILD}.tar.gz \
    && gunzip jetty-distribution-${JETTY_VERSION_MINOR}.${JETTY_VERSION_BUILD}.tar.gz \
    && tar -xf jetty-distribution-${JETTY_VERSION_MINOR}.${JETTY_VERSION_BUILD}.tar -C /opt/app \
    && rm jetty-distribution-${JETTY_VERSION_MINOR}.${JETTY_VERSION_BUILD}.tar \
    && mv /opt/app/jetty-* /opt/app/jetty \
    && mkdir /opt/app/jetty/tmp \
    && sed -i 's#<Set name="sendServerVersion"><Property name="jetty.send.server.version" default="true" /></Set>#<Set name="sendServerVersion"><Property name="jetty.send.server.version" default="false" /></Set>#' /opt/app/jetty/etc/jetty.xml \
    && sed -i 's#<New id="DefaultHandler" class="org.eclipse.jetty.server.handler.DefaultHandler"/>#<New id="DefaultHandler" class="org.eclipse.jetty.server.handler.DefaultHandler">\n               <Set name="serveIcon">false</Set>\n               <Set name="showContexts">false</Set>\n             </New>#' /opt/app/jetty/etc/jetty.xml \
    && curl -s -k -L -C - http://central.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/${MARIADB_VERSION}/mariadb-java-client-${MARIADB_VERSION}.jar > /opt/app/jetty/lib/ext/mariadb-java-client-${MARIADB_VERSION}.jar

EXPOSE 8080

ENTRYPOINT ["java", "-server", "-verbose:gc", "-XX:+UseCompressedOops", "-Djetty.home=/opt/app/jetty", "-Djetty.base=/opt/app/jetty", "-Djava.io.tmpdir=/opt/app/jetty/tmp", "-Djetty.state=/opt/app/jetty/jetty.state"]

CMD ["-Xms512m", "-Xmx512m", "-jar", "/opt/app/jetty/start.jar", "jetty-started.xml"]
