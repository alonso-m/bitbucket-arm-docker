![Atlassian Bitbucket Server](https://wac-cdn.atlassian.com/dam/jcr:bf39fc40-3871-491f-98e3-fb2293f57a00/bitbucket-icon-gradient-blue.svg?cdnVersion=696)

This is a fork of the original Atlassian Bitbucket server docker image modified to work on ARM architecture.

The original fork is here: https://bitbucket.org/atlassian-docker/docker-atlassian-bitbucket-server/src/master/

This repository consists of two branches: arm64v8 and arm32v7

# Overview

For instructions on how to run the docker images, please refer to the original Atlassian repository. The same instructions apply.

# Disclaimer

Note that Atlassian does not officially support Bitbucket server on ARM, however I have had no issues while running this custom docker image.
The only changes applied to the Dockerfile are basically changing the Java version that the image runs on.
