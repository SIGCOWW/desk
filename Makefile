NAME := lrks/desk
TAG := debug

.PHONY: build run release
build:
	cat Dockerfile.yml | ruby yml2dockerfile.rb > docker/Dockerfile
	sudo docker build --force-rm=true -t $(NAME):$(TAG) ./docker
run:
	sudo docker run --rm -it $(NAME):$(TAG) busybox ash
release:
	cat Dockerfile.yml | ruby yml2dockerfile.rb release > docker/Dockerfile
	sudo docker build --force-rm=true -t $(NAME):$(TAG) ./docker
