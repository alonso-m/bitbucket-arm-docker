#!/bin/bash
if [ "$UID" -eq 0 ]; then
    echo "User is currently root. Will change directory ownership to ${RUN_USER}:${RUN_GROUP}, then downgrade permission to ${RUN_USER}"
    mkdir -p "${BITBUCKET_HOME}/lib" &&
        chmod -R 700 "${BITBUCKET_HOME}" &&
        chown -R "${RUN_USER}:${RUN_GROUP}" "${BITBUCKET_HOME}"
    # Now drop privileges
    exec su -s /bin/bash "${RUN_USER}" -c "${BITBUCKET_INSTALL_DIR}/bin/start-bitbucket.sh $@"
else
    exec "${BITBUCKET_INSTALL_DIR}/bin/start-bitbucket.sh $@"
fi