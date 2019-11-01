SOURCE_DIR="/git_source"
DIST_DIR="/usr"

: ${BITBUCKET_VERSION=}
BITBUCKET_MINOR_VERSION=$(echo "${BITBUCKET_VERSION}" | cut -d. -f-2)


case ${BITBUCKET_MINOR_VERSION} in
    6.0)
        SUPPORTED_GIT_VERSION="2.20"
        ;;
    6.1)
        SUPPORTED_GIT_VERSION="2.20"
        ;;
    6.1)
        SUPPORTED_GIT_VERSION="2.20"
        ;;
    6.2)
        SUPPORTED_GIT_VERSION="2.21"
        ;;
    6.3)
        SUPPORTED_GIT_VERSION="2.21"
        ;;
    6.4)
        SUPPORTED_GIT_VERSION="2.22"
        ;;
    6.5)
        SUPPORTED_GIT_VERSION="2.22"
        ;;
    6.6)
        SUPPORTED_GIT_VERSION="2.23"
        ;;
    6.7)
        SUPPORTED_GIT_VERSION="2.23"
        ;;
    *)
        SUPPORTED_GIT_VERSION="2.23"
        ;;
esac


mkdir -p ${DIST_DIR}

# Install build dependencies
echo "Installing git build dependencies"
apt-get update
apt-get install -y --no-install-recommends git dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev

# Clone and checkout specific git version
git clone git://git.kernel.org/pub/scm/git/git.git ${SOURCE_DIR}
cd ${SOURCE_DIR}
GIT_VERSION=$(git tag | grep "^v${SUPPORTED_GIT_VERSION}\.[0-9]\+$" | sort | tail -n 1)
echo "Checking out ${GIT_VERSION}"
git checkout "${GIT_VERSION}"

# Uninstall pkg git
apt-get purge -y git

# Install git from source
make configure
./configure --prefix=${DIST_DIR}
make install

# Symlink redundant files to reduce image size
cd ${DIST_DIR}/libexec/git-core
for i in $(ls | grep -v "^git$"); do
    diff git $i
    if [ $? -eq 0 ]; then
        ln -sf $PWD/git $PWD/$i
    fi
done

# Remove build dir
rm -rf ${SOURCE_DIR}

# Remove and clean up dependencies
apt-get purge -y dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev
apt-get clean autoclean
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
