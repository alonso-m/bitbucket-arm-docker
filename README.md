![Atlassian Stash](https://www.atlassian.com/wac/software/stash/productLogo/imageBinary/stash_logo_productspage.png)

Stash is an on-premises source code management solution for Git that's secure, fast, and enterprise grade. Create and manage repositories, set up fine-grained permissions, and collaborate on code – all with the flexibility of your servers.

Learn more about Stash: <https://www.atlassian.com/software/stash>

# Overview

This Docker container makes it easy to get an instance of Stash up and running
for evaluative purposes. Atlassian is not yet able to provide support for using Docker in production.

# Quick Start

For the `STASH_HOME` directory that is used to store the repository data
(amongst other things) we recommend mounting a host directory as a [data volume](https://docs.docker.com/userguide/dockervolumes/#mount-a-host-directory-as-a-data-volume):

Set permissions for the data directory so that the runuser can write to it:

    $> docker run -u root -v /data/stash:/var/atlassian/application-data/stash atlassian/stash chown -R daemon  /var/atlassian/application-data/stash

Start Atlassian Stash:

    $> docker run -v /data/stash:/var/atlassian/application-data/stash --name="stash" -d -p 7990:7990 -p 7999:7999 atlassian/stash
    
**Success**. Stash is now available on [http://localhost:7990](http://localhost:7990)*


_* Note: If you are using `boot2docker` on Mac OS X, please use `open http://$(boot2docker ip):7990` instead._

# Upgrade

To upgrade to a more recent version of Stash you can simply stop the `stash`
container and start a new one based on a more recent image:

    $> docker stop stash
    $> docker rm stash
    $> docker run ... (See above)

As your data is stored in the data volume directory on the host it will still
be available after the upgrade.

_Note: Please make sure that you **don't** accidentally remove the `stash`
container and its volumes using the `-v` option._

# Backup

For evalutations you can use the built-in database that will store its files in the Stash home directory. In that case it is sufficient to create a backup archive of the directory on the host that is used as a volume (`/data/stash` in the example above).

The [Stash Backup Client](https://confluence.atlassian.com/display/STASH/Data+recovery+and+backups) is currently not supported in the Docker setup. You can however use the [Stash DIY Backup](https://confluence.atlassian.com/display/STASH/Using+Stash+DIY+Backup) approach in case you decided to use an external database.

Read more about data recovery and backups: [https://confluence.atlassian.com/display/STASH/Data+recovery+and+backups](https://confluence.atlassian.com/display/STASH/Data+recovery+and+backups)

# Versioning

The `latest` tag matches the most recent release of Atlassian Stash.
Thus `atlassian/stash:latest` will use the newest version of Stash available.

Alternatively you can use a specific minor version of Stash by using a version number
tag: `atlassian/stash:3.5`. This will install the latest `3.5.x` version that
is available.


# Issue tracker

Please raise an
[issue](https://bitbucket.org/atlassian/docker-atlassian-stash/issues) if you
encounter any problems with this Dockerfile.