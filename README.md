![Atlassian Bitbucket Server](https://www.atlassian.com/dam/wac/legacy/bitbucket_logo_landing.png)

Bitbucket Server is an on-premises source code management solution for Git
that's secure, fast, and enterprise grade. Create and manage repositories, set
up fine-grained permissions, and collaborate on code - all with the flexibility
of your servers.

Learn more about Bitbucket Server: <https://www.atlassian.com/software/bitbucket/server>

# Overview

This Docker container makes it easy to get an instance of Bitbucket up and
running.

** We strongly recommend you run this image using a specific version tag instead
of latest. This is because the image referenced by the latest tag changes often
and we cannot guarantee that it will be backwards compatible. **

# Quick Start

For the `BITBUCKET_HOME` directory that is used to store the repository data
(amongst other things) we recommend mounting a host directory as a 
[data volume](https://docs.docker.com/engine/tutorials/dockervolumes/#/data-volumes),
or via a named volume if using a docker version >= 1.9.

Additionally, if running Bitbucket in Data Center mode it is required that a
shared filesystem is mounted.

Volume permission is managed by entry scripts. To get started you can use a data
volume, or named volumes. In this example we'll use named volumes.

    $> docker volume create --name bitbucketVolume
    $> docker run -v bitbucketVolume:/var/atlassian/application-data/bitbucket --name="bitbucket" -d -p 7990:7990 -p 7999:7999 atlassian/bitbucket-server

Note that this command can substitute folder paths with named volumes.

Start Atlassian Bitbucket Server:

    $> docker run -v /data/bitbucket:/var/atlassian/application-data/bitbucket --name="bitbucket" -d -p 7990:7990 -p 7999:7999 atlassian/bitbucket-server

**Success**. Bitbucket is now available on [http://localhost:7990](http://localhost:7990)*

Please ensure your container has the necessary resources allocated to it.
We recommend 2GiB of memory allocated to accommodate both the application server
and the git processes.
See [Supported Platforms](https://confluence.atlassian.com/display/BitbucketServer/Supported+platforms) for further information.
    

_* Note: If you are using `docker-machine` on Mac OS X, please use `open http://$(docker-machine ip default):7990` instead._

## Common settings

### Reverse Proxy Settings

If Bitbucket is run behind a reverse proxy server as 
[described here](https://confluence.atlassian.com/bitbucketserver/proxying-and-securing-bitbucket-server-776640099.html),
then you need to specify extra options to make Bitbucket aware of the
setup. They can be controlled via the below environment variables.

* `SERVER_PROXY_NAME` (default: NONE)

   The reverse proxy's fully qualified hostname.

* `SERVER_PROXY_PORT` (default: NONE)

   The reverse proxy's port number via which bitbucket is accessed.

* `SERVER_SCHEME` (default: http)

   The protocol via which bitbucket is accessed.

* `SERVER_SECURE` (default: false)

   Set 'true' if SERVER\_SCHEME is 'https'.

### JVM Configuration (Bitbucket Server 5.0 + only)

If you need to override Bitbucket Server's default memory configuration or pass
additional JVM arguments, use the environment variables below

* `JVM_MINIMUM_MEMORY` (default: 512m)

   The minimum heap size of the JVM

* `JVM_MAXIMUM_MEMORY` (default: 1024m)

   The maximum heap size of the JVM

* `JVM_SUPPORT_RECOMMENDED_ARGS` (default: NONE)

   Additional JVM arguments for Bitbucket Server, such as a custom Java Trust Store

### Application Mode Settings (Bitbucket Server 5.0 + only)

This docker image can be run as a 
[Smart Mirror](https://confluence.atlassian.com/bitbucketserver/smart-mirroring-776640046.html)
or as part of a 
[Data Center](https://confluence.atlassian.com/enterprise/bitbucket-data-center-668468332.html)
cluster.  You can specify the following properties to start Bitbucket as a
mirror or as a Data Center node:

* `ELASTICSEARCH_ENABLED` (default: true)

  Set 'false' to prevent Elasticsearch from starting in the container. This
  should be used if Elasticsearch is running remotely, e.g. for if Bitbucket is
  running in a Data Center cluster

* `APPLICATION_MODE` (default: default)

   The mode Bitbucket will run in. This can be set to 'mirror' to start
   Bitbucket as a Smart Mirror. This will also disable Elasticsearch even if
   `ELASTICSEARCH_ENABLED` has not been set to 'false'.

## Other settings

As well as the above settings, all settings that are available in the
[bitbucket.properties
file](https://confluence.atlassian.com/bitbucketserver/bitbucket-server-config-properties-776640155.html)
can also be provided via Docker environment variables. For example, to configure
the database automatically, you would set the following via `--env` (or
`--env-file`):

* `JDBC_DRIVER`
* `JDBC_URL`
* `JDBC_USER`
* `JDBC_PASSWORD`

These correspond to the following settings in
[bitbucket.properties](https://confluence.atlassian.com/bitbucketserver/bitbucket-server-config-properties-776640155.html):

* `jdbc.driver`
* `jdbc.url`
* `jdbc.user`
* `jdbc.password`

Other setting you may want to specify are clustering are clustering settings
(`HAZELCAST_*`) and JMX monitoring (`JMX_*`). A full command-line for a TCP
clustered instance, with a PostgreSQL database, and an external ElasticSearch
instance might look like:

    $> docker network create --driver bridge --subnet=172.18.0.0/16 myBitbucketNetwork
    $> docker run --network=myBitbucketNetwork --ip=172.18.1.1 \
        -e ELASTICSEARCH_ENABLED=false \
        -e JDBC_DRIVER=org.postgresql.Driver \
        -e JDBC_USER=atlbitbucket \
        -e JDBC_PASSWORD=MYPASSWORDSECRET \
        -e JDBC_URL=jdbc:postgresql://my.database.host:5432/bitbucket \
        -e PLUGIN_SEARCH_ELASTICSEARCH_BASEURL=http://my.elasticsearch.host \
        -e HAZELCAST_NETWORK_TCPIP=true \
        -e HAZELCAST_NETWORK_TCPIP_MEMBERS=172.18.1.1:5701,172.18.1.2:5701,172.18.1.3:5701 \
        -e HAZELCAST_GROUP_NAME=bitbucket \
        -e HAZELCAST_GROUP_PASSWORD=mysecretpassword \
        -v /data/bitbucket-shared:/var/atlassian/application-data/bitbucket/shared \
        --name="bitbucket" \
        -d -p 7990:7990 -p 7999:7999 \
        atlassian/bitbucket-server

For more information on clustering Bitbucket, and other properties see
[Clustering with Bitbucket Data Center](https://confluence.atlassian.com/bitbucketserver/clustering-with-bitbucket-data-center-776640164.html)
and [Clustering with Bitbucket Data Center](https://confluence.atlassian.com/bitbucketserver/bitbucket-server-config-properties-776640155.html).

# Shared directory and user IDs

By default the Bitbucket application runs as the user `bitbucket`, with a UID
and GID of 2003. Consequently this UID must have write access to the shared
filesystem. If for some reason a different UID must be used, there are a number
of options available:

* The Docker image can be rebuilt with a different UID.
* Under Linux, the UID can be remapped using 
  [user namespace remapping](https://docs.docker.com/engine/security/userns-remap/).

# Upgrade

To upgrade to a more recent version of Bitbucket Server you can simply stop the `bitbucket`
container and start a new one based on a more recent image:

    $> docker stop bitbucket
    $> docker rm bitbucket
    $> docker pull atlassian/bitbucket-server:<desired_version>
    $> docker run ... (See above)

As your data is stored in the data volume directory on the host it will still
be available after the upgrade.

_Note: Please make sure that you **don't** accidentally remove the `bitbucket`
container and its volumes using the `-v` option._

# Backup

For evaluations you can use the built-in database that will store its files in
the Bitbucket Server home directory. In that case it is sufficient to create a
backup archive of the directory on the host that is used as a volume
(`/data/bitbucket` in the example above).

The [Bitbucket Server Backup Client](https://confluence.atlassian.com/display/BitbucketServer/Data+recovery+and+backups)
is currently not supported in the Docker setup. You can however use the
[Bitbucket Server DIY Backup](https://confluence.atlassian.com/display/BitbucketServer/Using+Bitbucket+Server+DIY+Backup)
approach in case you decided to use an external database.

Read more about data recovery and backups:
[https://confluence.atlassian.com/display/BitbucketServer/Data+recovery+and+backups](https://confluence.atlassian.com/display/BitbucketServer/Data+recovery+and+backups)

# Versioning

The `latest` tag matches the most recent version of this repository. Thus using
`atlassian/bitbucket:latest` or `atlassian/bitbucket` will ensure you are
running the most up to date version of this image.

However, we ** strongly recommend ** that for non-eval workloads you select a
specific version in order to prevent breaking changes from impacting your setup.
You can use a specific minor version of Bitbucket Server by using a version
number tag: `atlassian/bitbucket-server:4.14`. This will install the latest
`4.14.x` version that is available.


# Issue tracker

Please raise an
[issue](https://bitbucket.org/atlassian/docker-atlassian-bitbucket-server/issues)
if you encounter any problems with this Dockerfile.

# Support

For product support, go to [support.atlassian.com](https://support.atlassian.com/)

# License

Copyright © 2019 Atlassian Corporation Pty Ltd.
Licensed under the Apache License, Version 2.0.
