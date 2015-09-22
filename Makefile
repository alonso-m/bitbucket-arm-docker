

build:
	docker build -t="atlassian/bitbucket" .

run: data
	docker run --volumes-from bitbucket-data --name="bitbucket" -d -p 7990:7990 -p 7999:7999 atlassian/bitbucket

data:
	docker run -d -v /var/atlassian/application-data/bitbucket --name="bitbucket-data" atlassian/bitbucket-data

.PHONY: build run data
