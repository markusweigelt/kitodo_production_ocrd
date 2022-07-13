FROM tomcat:9.0.62-jre11-openjdk-slim

MAINTAINER markus.weigelt@slub-dresden.de
ARG VCS_REF
ARG BUILD_DATE
LABEL \
    maintainer="https://slub-dresden.de" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/markusweigelt/kitodo-production-docker/tree/main/kitodo" \
    org.label-schema.build-date=$BUILD_DATE

ARG BUILD_RESOURCES

RUN if [[ -z "$BUILD_RESOURCES" ]] ; then echo BUILD_RESOURCES not provided ; else echo BUILD_RESOURCES is $BUILD_RESOURCES ; fi

ENV JAVA_OPTS="-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xmx4G -XX:MaxPermSize=256m"
ENV JPDA=false
ENV JPDA_ADDRESS=*:5005

ENV KITODO_DB_HOST=localhost
ENV KITODO_DB_PORT=3306
ENV KITODO_DB_NAME=kitodo
ENV KITODO_DB_USER=kitodo
ENV KITODO_DB_PASSWORD=kitodo
ENV KITODO_ES_HOST=localhost
ENV KITODO_MQ_HOST=localhost
ENV KITODO_MQ_PORT=61616

# make apt run non-interactive during build
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y \
	apt-utils \
	net-tools \
	nano \
	unzip \
	procps \
	dnsutils \
	mariadb-client \
	openssh-client \
	imagemagick \
	rsyslog \
	--no-install-recommends

ARG BUILD_RESOURCE_WAR=kitodo.war
ARG BUILD_RESOURCE_CONFIG_MODULES=kitodo-config-modules.zip
ARG BUILD_RESOURCE_SQL=kitodo.sql

COPY ${BUILD_RESOURCES}/${BUILD_RESOURCE_WAR} /tmp/kitodo/kitodo.war
COPY ${BUILD_RESOURCES}/${BUILD_RESOURCE_CONFIG_MODULES} /tmp/kitodo/kitodo-config-modules.zip
COPY ${BUILD_RESOURCES}/${BUILD_RESOURCE_SQL} /tmp/kitodo/kitodo.sql

COPY tomcat.conf /etc/rsyslog.d/
COPY startup.sh /usr/bin/
COPY deploy.sh /usr/bin/

ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /tmp/wait-for-it.sh

# system configs
RUN mkdir /.ssh && \
    cat > /etc/ssh/ssh_known_hosts && \
    chmod +x /usr/bin/startup.sh && \
    chmod +x /usr/bin/deploy.sh && \
    chmod +x /tmp/wait-for-it.sh

# application configs
RUN unzip /tmp/kitodo/kitodo-config-modules.zip -x *.bat -d /tmp/kitodo/kitodo-config-modules-unzipped && \
    chmod -R go+w /tmp/kitodo/kitodo-config-modules-unzipped && \
    mkdir -p /tmp/kitodo/kitodo-config-modules /tmp/kitodo/overwrites/data /tmp/kitodo/overwrites/sql && \
    touch /tmp/kitodo/overwrites/sql/kitodo_post_init.sql && \
    mv /tmp/kitodo/kitodo-config-modules-unzipped/* /tmp/kitodo/kitodo-config-modules && \
    chmod 544 /tmp/kitodo/kitodo-config-modules/scripts/*.sh && \
    rm -f /tmp/kitodo/kitodo-config-modules.zip && \
    rm -d /tmp/kitodo/kitodo-config-modules-unzipped

CMD ["/usr/bin/startup.sh"]

EXPOSE 8080

# make apt run interactive during logins
ENV DEBIAN_FRONTEND teletype
