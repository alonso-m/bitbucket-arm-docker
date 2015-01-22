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
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
VERSION=$1

$DIR/change-stash-version.sh $VERSION

git add Dockerfile
git commit -m "Rev Atlassian Stash version to $VERSION"
