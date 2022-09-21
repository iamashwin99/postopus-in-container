image:
	docker build -f Dockerfile -t live-octopus .

image-no-cache:
	docker build --no-cache -f Dockerfile -t live-octopus .

run:
	docker run -p 8888:8888 -it -v `realpath .`:/home/karnada/io  live-octopus env TERM=xterm-256color bash -l
