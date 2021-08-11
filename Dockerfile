ARG BASE_IMAGE=arm64v8/adoptopenjdk:11-jdk-hotspot
FROM $BASE_IMAGE

ARG BITBUCKET_VERSION=7.15.1
ARG PLATFORM=arm64

ENV RUN_USER                                        bitbucket
ENV RUN_GROUP                                       bitbucket
ENV RUN_UID                                         2003
ENV RUN_GID                                         2003

# https://confluence.atlassian.com/display/BitbucketServer/Bitbucket+Server+home+directory
ENV BITBUCKET_HOME                                  /var/atlassian/application-data/bitbucket
ENV BITBUCKET_INSTALL_DIR                           /opt/atlassian/bitbucket
ENV ELASTICSEARCH_ENABLED                           true
ENV APPLICATION_MODE                                default

WORKDIR $BITBUCKET_HOME

# Expose HTTP and SSH ports
EXPOSE 7990
EXPOSE 7999

CMD ["/entrypoint.py"]
ENTRYPOINT ["/sbin/tini", "--"]

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends fontconfig openssh-client perl python3 python3-jinja2 \
    && apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

COPY bin/make-git.sh                                /
RUN /make-git.sh

ARG TINI_VERSION=v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-${PLATFORM} /sbin/tini
RUN chmod +x /sbin/tini

ARG DOWNLOAD_URL=https://product-downloads.atlassian.com/software/stash/downloads/atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz

RUN groupadd --gid ${RUN_GID} ${RUN_GROUP} \
    && useradd --uid ${RUN_UID} --gid ${RUN_GID} --home-dir ${BITBUCKET_HOME} --shell /bin/bash ${RUN_USER} \
    && echo PATH=$PATH > /etc/environment \
    \
    && mkdir -p                                     ${BITBUCKET_INSTALL_DIR} \
    && curl -L --silent                             ${DOWNLOAD_URL} | tar -xz --strip-components=1 -C "${BITBUCKET_INSTALL_DIR}" \
    && chmod -R "u=rwX,g=rX,o=rX"                   ${BITBUCKET_INSTALL_DIR}/ \
    && chown -R root.                               ${BITBUCKET_INSTALL_DIR}/ \
    && chown -R ${RUN_USER}:${RUN_GROUP}            ${BITBUCKET_INSTALL_DIR}/elasticsearch/logs \
    && chown -R ${RUN_USER}:${RUN_GROUP}            ${BITBUCKET_HOME} \
    \
    && sed -i -e 's/^# umask/umask/'         ${BITBUCKET_INSTALL_DIR}/bin/_start-webapp.sh

VOLUME ["${BITBUCKET_HOME}"]

COPY entrypoint.py \
     shared-components/image/entrypoint_helpers.py  /
COPY shared-components/support                      /opt/atlassian/support
