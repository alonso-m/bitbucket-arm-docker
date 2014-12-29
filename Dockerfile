FROM java:openjdk-7-jre
MAINTANER Atlassian Stash Team

ENV STASH_VERSION 3.5.1

# https://confluence.atlassian.com/display/STASH/Stash+home+directory
ENV STASH_HOME          /var/atlassian/application-data/stash

# Install Atlassian Stash to the following location
ENV STASH_INSTALL_DIR   /opt/atlassian/stash

ENV DOWNLOAD_URL        http://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-


# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'nobody' but
# here we only ever run one process anyway.
ENV RUN_USER            nobody
ENV RUN_GROUP           nogroup


# Install git, download and extract Stash and create the required directory layout.
# Keep this as a single command to minimise the number of layers that will need to be created.
RUN set -x && apt-get update -qq                                                  \
    && apt-get install -y --no-install-recommends                                 \
            git                                                                   \
    && apt-get clean autoclean                                                    \
    && apt-get autoremove --yes                                                   \
    && rm -rf                  /var/lib/{apt,dpkg,cache,log}/                     \
    && mkdir -p                $STASH_HOME                                        \
    && chmod -R 700            $STASH_HOME                                        \
    && chown -R ${RUN_USER}:${RUN_GROUP} $STASH_HOME                              \
    && mkdir -p                $STASH_INSTALL_DIR                                 \
    && curl -L                 ${DOWNLOAD_URL}${STASH_VERSION}.tar.gz | tar -xz --strip-components=1 -C "$STASH_INSTALL_DIR" \
    && mkdir -p                          ${STASH_INSTALL_DIR}/conf/Catalina      \
    && chmod -R 700                      ${STASH_INSTALL_DIR}/conf/Catalina      \
    && chmod -R 700                      ${STASH_INSTALL_DIR}/logs               \
    && chmod -R 700                      ${STASH_INSTALL_DIR}/temp               \
    && chmod -R 700                      ${STASH_INSTALL_DIR}/work               \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${STASH_INSTALL_DIR}/logs               \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${STASH_INSTALL_DIR}/temp               \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${STASH_INSTALL_DIR}/work               \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${STASH_INSTALL_DIR}/conf 

USER ${RUN_USER}:${RUN_GROUP}

VOLUME ["${STASH_HOME}", "${STASH_INSTALL_DIR}"]

# HTTP Port
EXPOSE 7990

# SSH Port
EXPOSE 7999

WORKDIR $STASH_INSTALL_DIR

# Run in foreground
CMD ["./bin/start-stash.sh", "-fg"]
