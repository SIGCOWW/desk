NAME := lrks/desk
TAG := debug

.PHONY: build run
build:
	sudo docker build --force-rm=true -t $(NAME):$(TAG) ./docker
run:
	sudo docker run --rm -it $(NAME):$(TAG) busybox ash
