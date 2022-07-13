TAGNAME ?= bertsky/ocrd_controller
SHELL = /bin/bash

build:
	docker build \
	--build-arg VCS_REF=$$(git rev-parse --short HEAD) \
	--build-arg BUILD_DATE=$$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
	--network=host -t $(TAGNAME) .

define HELP
cat <<"EOF"
Targets:
	- build	(re)compile Docker image from sources
	- run	start up Docker container with SSH service
	- test	check all installed processors

Variables:
	- TAGNAME	name of Docker image to build/run
	  currently: "$(TAGNAME)"
	- KEYS		file to mount as .ssh/authorized_keys
	  currently: "$(KEYS)"
	- DATA		host directory to mount into `/data`
	  currently: "$(DATA)"
	- MODELS	resource data directory to mount into `/models`
	  currently: "$(MODELS)"
	- CONFIG	resource config directory to mount into `/models`
	  currently: "$(CONFIG)"
	- UID		user id to use in logins
	  currently: $(UID)
	- GID		group id to use in logins
	  currently: $(GID)
	- UMASK		user mask to use in logins
	  currently: $(UMASK)
	- PORT		TCP port for the (host-side) sshd server
	  currently: $(PORT)
	- NETWORK	Docker network to use (manage via "docker network")
	  currently: $(NETWORK)
	- WORKERS	number of concurrent jobs allowed in logins
	  currently: $(WORKERS)
EOF
endef
export HELP
help: ; @eval "$$HELP"

KEYS ?= $(firstword $(wildcard $(HOME)/.ssh/authorized_keys* $(HOME)/.ssh/id_*.pub))
DATA ?= $(CURDIR)
MODELS ?= $(HOME)/.local/share
CONFIG ?= $(HOME)/.config
UID ?= $(shell id -u)
GID ?= $(shell id -g)
UMASK ?= 0002
PORT ?= 8022
NETWORK ?= bridge
WORKERS ?= 1
# FIXME: map host to container UIDs so that logins will modify data on volumes with host UID not as root
run: $(DATA) $(MODELS) $(KEYS)
	docker run --rm \
	-p $(PORT):22 \
	-h ocrd_controller \
	--name ocrd_controller \
	--network=$(NETWORK) \
	-v $(DATA):/data \
	-v $(MODELS):/models \
	-v $(CONFIG):/config \
	--tmpfs /tmp:rw,noexec,nosuid,nodev,size=2g \
	--mount type=bind,source=$(KEYS),target=/authorized_keys \
	-e UID=$(UID) -e GID=$(GID) -e UMASK=$(UMASK) -e WORKERS=$(WORKERS) \
	--cpus=$(WORKERS) --gpus=all -d $(TAGNAME)

test:
	ssh -Tn -p $(PORT) ocrd@localhost make -C /build check

.PHONY: build run help test
