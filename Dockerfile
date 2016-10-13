FROM oberthur/docker-ubuntu-java:jdk8_8.102.14

MAINTAINER Dawid Malinowski <d.malinowski@oberthur.com>

ENV HOME=/opt/app \
    JETTY_VERSION_MAJOR=9 \
    JETTY_VERSION_MINOR=9.2.19 \
    JETTY_VERSION_BUILD=v20160908

WORKDIR /opt/app

# Install Jetty 9
RUN curl -L -O http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VERSION_MINOR}.${JETTY_VERSION_BUILD}/jetty-distribution-${JETTY_VERSION_MINOR}.${JETTY_VERSION_BUILD}.tar.gz \
    && echo http://download.eclipse.org/jetty/stable-${JETTY_VERSION_MAJOR}/dist/jetty-distribution-${JETTY_VERSION_MINOR}.${JETTY_VERSION_BUILD}.tar.gz \
    && gunzip jetty-distribution-${JETTY_VERSION_MINOR}.${JETTY_VERSION_BUILD}.tar.gz \
    && tar -xf jetty-distribution-${JETTY_VERSION_MINOR}.${JETTY_VERSION_BUILD}.tar -C /opt/app \
    && rm jetty-distribution-${JETTY_VERSION_MINOR}.${JETTY_VERSION_BUILD}.tar \
    && mv /opt/app/jetty-* /opt/app/jetty \
    && mkdir /opt/app/jetty/tmp \
    && mkdir /opt/app/base \
    && curl -k https://raw.githubusercontent.com/jetty-project/logging-modules/master/logback/logging.mod > /opt/app/jetty/modules/logging.mod \
    && sed -i 's#<Set name="sendServerVersion"><Property name="jetty.send.server.version" default="true" /></Set>#<Set name="sendServerVersion"><Property name="jetty.send.server.version" default="false" /></Set>#' /opt/app/jetty/etc/jetty.xml \
    && sed -i 's#<New id="DefaultHandler" class="org.eclipse.jetty.server.handler.DefaultHandler"/>#<New id="DefaultHandler" class="org.eclipse.jetty.server.handler.DefaultHandler">\n               <Set name="serveIcon">false</Set>\n               <Set name="showContexts">false</Set>\n             </New>#' /opt/app/jetty/etc/jetty.xml \
    && java -jar -Djetty.base=/opt/app/base /opt/app/jetty/start.jar --add-to-start=http,plus,jsp,jndi,annotations,deploy,logging,ext \
    && ln -s /opt/app /home/app

# Add user app
RUN groupadd -g 999 app \
    && useradd -u 999 app -g app -s /bin/false -M -d /opt/app \
    && mkdir -p /opt/app/logs/archives \
    && chown -R app:app /opt/app

ENTRYPOINT ["java", "-server", "-Duser.home=/opt/app", "-verbose:gc", "-XX:+UseCompressedOops", "-Djetty.home=/opt/app/jetty", "-Djetty.base=/opt/app/base", "-Djava.io.tmpdir=/opt/app/jetty/tmp", "-Djetty.state=/opt/app/jetty/jetty.state"]

CMD ["-Xms512m", "-Xmx512m", "-jar", "/opt/app/jetty/start.jar", "jetty-started.xml"]
