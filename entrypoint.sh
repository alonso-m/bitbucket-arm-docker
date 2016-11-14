#!/bin/bash

# Credit to codemedic NA for this file
if [ "$UID" -eq 0 ]; then
    mkdir -p ${BITBUCKET_HOME}/lib &&
        chmod -R 700 "${BITBUCKET_HOME}" &&
        chown -R ${RUN_USER}:${RUN_GROUP} "${BITBUCKET_HOME}"
    # Now drop privileges
    exec su -s /bin/bash -m ${RUN_USER} -c "$BITBUCKET_INSTALL_DIR/bin/start-bitbucket.sh $@" 
else
    exec $BITBUCKET_INSTALL_DIR/bin/start-bitbucket.sh "$@"
fi
