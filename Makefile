###
# The command `$(git rev-parse --abbrev-ref HEAD | sed 's/[^a-zA-Z0-9]/-/g')`
# checks the name of the git branch and replaces all non-alphanumeric characters with a dash.
###

image:
	docker build -f Dockerfile -t live-octopus:$(git rev-parse --abbrev-ref HEAD | sed 's/[^a-zA-Z0-9]/-/g') .

image-no-cache:
	docker build --no-cache -f Dockerfile -t live-octopus:$(git rev-parse --abbrev-ref HEAD | sed 's/[^a-zA-Z0-9]/-/g') .

run:
	docker run -p 8888:8888 -it -v `realpath .`:/home/karnada/io  live-octopus:$(git rev-parse --abbrev-ref HEAD | sed 's/[^a-zA-Z0-9]/-/g') env TERM=xterm-256color bash -l
