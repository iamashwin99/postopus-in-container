###
# The command `$(git rev-parse --abbrev-ref HEAD | sed 's/[^a-zA-Z0-9]/-/g')`
# checks the name of the git branch and replaces all non-alphanumeric characters with a dash.
###

gitBranch=`git rev-parse --abbrev-ref HEAD | sed 's/[^a-zA-Z0-9]/-/g'`
dockerUser=`whoami`

image:
	docker build --build-arg DOCKER_USER=${dockerUser} -f Dockerfile -t live-octopus:${gitBranch} .

image-no-cache:
	docker build --build-arg DOCKER_USER=${dockerUser} --no-cache -f Dockerfile -t live-octopus:${gitBranch} .

run:
	docker run -p 8888:8888 -it -v `realpath .`:/home/karnada/io  live-octopus:${gitBranch} env TERM=xterm-256color bash -l
