# Quick Start

We recommend using a separate Data Volume Container for the `STASH_HOME`
directory. This will allow you to upgrade the Stash instance independently:

Start the Data Volume Container:

    $> docker run -d -v /var/atlassian/application-data/stash --name stash-data ssaasen/stash-data

Start Atlassian Stash:


    $> docker run --volumes-from stash-data \
            --name="stash" \
            -d \
            -p 7990:7990 \
            -p 7999:7999 \
            ssaasen/stash


**Success**. Stash is now available on [http://localhost:7990](http://localhost:7990)*


_* Note: If you are using `boot2docker` on Mac OS X, please use `open http://$(boot2docker ip):7990` instead._

# Upgrade

To upgrade to a more recent version of Stash you can simply stop the `stash`
container and start a new one based on a more recent image:

    $> docker stop stash
    $> docker rm stash
    $> docker run ... (See above)

As your data is stored in the `stash-data` data volume container it will still
be available after the upgrade.

_Note: Please make sure that you don't accidentially remove the `stash-data`
container._

# Versioning

The `latest` tag matches the most recent release of Atlassian Stash.
Thus `atlassian/stash:latest` will use the newest version of Stash available.

Alternatively you can use a specific version of Stash by using a version number
tag: `atlassian/stash:3.4.0`
