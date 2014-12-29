

build:
	docker build -t="ssaasen/stash" .

run: data
	docker run --volumes-from stash-data --name="stash" -d -p 7990:7990 -p 7999:7999 ssaasen/stash

data:
	docker run -d -v /var/atlassian/application-data/stash --name stash-data ssaasen/stash-data || docker start -ia stash-data


.PHONY: build run data
