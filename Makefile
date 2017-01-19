all: build

PROJECT=carylorrk/geeps
#CONTAINER_NAME=$(PROJECT):$(shell git rev-parse --abbrev-ref HEAD | sed 's/master/latest/')
CONTAINER_NAME=$(PROJECT):latest

NUM_SOCKET=$(shell lscpu | grep ^Socket\(s\) | cut -d':' -f2 )
NUM_CPU=$(shell lscpu | grep ^CPU\(s\): | cut -d':' -f2 )
NUM_THREAD=$(shell lscpu | grep ^Thread\(s\) | cut -d':' -f2 ) 

attach:
	nvidia-docker exec -it geeps bash

rmf:
	docker rm -f geeps

run:
	nvidia-docker run -d --name geeps $(CONTAINER_NAME)

rebuild:
	docker build --no-cache -t $(CONTAINER_NAME) --build-arg NUM_CORE=`expr $(NUM_SOCKET) \* $(NUM_CPU) \* $(NUM_THREAD)` .
	
build:
	docker build -t $(CONTAINER_NAME) --build-arg NUM_CORE=`expr $(NUM_SOCKET) \* $(NUM_CPU) \* $(NUM_THREAD)` .

.PHONY: build rebuild
