#!/bin/bash -e 

if [ "x$1" == "x" ]; then
    echo "Usage:"
    echo ""
    echo "$0 VERSION"
    echo ""
    echo "E.g."
    echo ""
    echo "$0 3.5.1"
    exit -1
fi


VERSION=$1

sed -i '' -e "s/ENV STASH_VERSION.*/ENV STASH_VERSION ${VERSION}/g" Dockerfile

git add Dockerfile
git commit -m "Rev Atlassian Stash version to $VERSION"
