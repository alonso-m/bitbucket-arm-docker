![Atlassian Bitbucket Server](https://www.atlassian.com/dam/wac/legacy/bitbucket_logo_landing.png)

Bitbucket Server is an on-premises source code management solution for Git that's secure, fast, and enterprise grade. Create and manage repositories, set up fine-grained permissions, and collaborate on code – all with the flexibility of your servers.

Learn more about Bitbucket Server: <https://www.atlassian.com/software/bitbucket>

# Overview

This Docker container makes it easy to get an instance of Bitbucket up and running.

# Quick Start

For the `BITBUCKET_HOME` directory that is used to store the repository data
(amongst other things) we recommend mounting a host directory as a [data volume](https://docs.docker.com/userguide/dockervolumes/#mount-a-host-directory-as-a-data-volume):

Set permissions for the data directory so that the runuser can write to it:

    $> docker run -u root -v /data/bitbucket:/var/atlassian/application-data/bitbucket atlassian/bitbucket-server chown -R daemon  /var/atlassian/application-data/bitbucket

Start Atlassian Bitbucket Server:

    $> docker run -v /data/bitbucket:/var/atlassian/application-data/bitbucket --name="bitbucket" -d -p 7990:7990 -p 7999:7999 atlassian/bitbucket-server

**Success**. Bitbucket is now available on [http://localhost:7990](http://localhost:7990)*

Please ensure your container has the necessary resources allocated to it.
We recommend 2GiB of memory allocated to accommodate both the application server
and the git processes.
See [Supported Platforms](https://confluence.atlassian.com/display/BitbucketServer/Supported+platforms) for further information.
    

_* Note: If you are using `docker-machine` on Mac OS X, please use `open http://$(docker-machine ip default):7990` instead._

## Reverse Proxy Settings

If bitbucket is run behind a reverse proxy server as [described here](https://confluence.atlassian.com/bitbucketserver/proxying-and-securing-bitbucket-server-776640099.html),
then you need to specify extra options to make bitbucket aware of the setup. They can be controlled via the below
environment variables.

* `CATALINA_CONNECTOR_PROXYNAME` (default: NONE)
    The reverse proxy's fully qualified hostname.

* `CATALINA_CONNECTOR_PROXYPORT` (default: NONE)
    The reverse proxy's port number via which bitbucket is accessed.

* `CATALINA_CONNECTOR_SCHEME` (default: http)
    The protocol via which bitbucket is accessed.

* `CATALINA_CONNECTOR_SECURE` (default: false)
    Set 'true' if CATALINA_CONNECTOR_SCHEME is 'https'.

# Upgrade

To upgrade to a more recent version of Bitbucket Server you can simply stop the `bitbucket`
container and start a new one based on a more recent image:

    $> docker stop bitbucket
    $> docker rm bitbucket
    $> docker run ... (See above)

As your data is stored in the data volume directory on the host it will still
be available after the upgrade.

_Note: Please make sure that you **don't** accidentally remove the `bitbucket`
container and its volumes using the `-v` option._

# Backup

For evaluations you can use the built-in database that will store its files in the Bitbucket Server home directory. In that case it is sufficient to create a backup archive of the directory on the host that is used as a volume (`/data/bitbucket` in the example above).

The [Bitbucket Server Backup Client](https://confluence.atlassian.com/display/BitbucketServer/Data+recovery+and+backups) is currently not supported in the Docker setup. You can however use the [Bitbucket Server DIY Backup](https://confluence.atlassian.com/display/BITBUCKET+SERVER/Using+Bitbucket+DIY+Backup) approach in case you decided to use an external database.

Read more about data recovery and backups: [https://confluence.atlassian.com/display/BitbucketServer/Data+recovery+and+backups](https://confluence.atlassian.com/display/BitbucketServer/Data+recovery+and+backups)

# Versioning

The `latest` tag matches the most recent release of Atlassian Bitbucket Server.
Thus `atlassian/bitbucket:latest` will use the newest version of Bitbucket Server available.

Alternatively you can use a specific minor version of Bitbucket Server by using a version number
tag: `atlassian/bitbucket-server:4.0`. This will install the latest `4.0.x` version that
is available.


# Issue tracker

Please raise an
[issue](https://bitbucket.org/atlassian/docker-atlassian-bitbucket-server/issues) if you
encounter any problems with this Dockerfile.

# Support

For product support, go to [support.atlassian.com](https://support.atlassian.com/)
