image:
	docker build -f Dockerfile -t live-octopus .

image-no-cache:
	docker build --no-cache -f Dockerfile -t live-octopus .

run:
	docker run -p 8888:8888 -ti -v $PWD:/io  live-octopus env TERM=xterm-256color bash -l

run-mount:
	docker run -p 8888:8888 -ti -v $PWD:/io --mount type=bind,source=`realpath ..`/tmps,target=/tmps  live-octopus env TERM=xterm-256color bash -l