URL="http://localhost:7990/status"

echo "Wait for the container to come up and Stash to start"
until $(curl --output /dev/null --silent --head --fail $URL); do
    printf '.'
    sleep 5
done

# Now the container is up and running and Stash is running. Let's wait until it shows the setup screen
echo "Check the /status output"
curl -v $URL | grep FIRST_RUN
ret=$?
if [ "$ret" != "0" ]; then
    echo "Unexpected /status response"
    exit $ret
else
    echo "Stash seems to be up and running"
    exit 0
fi
