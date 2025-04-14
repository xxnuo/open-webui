
ifneq ($(shell which docker-compose 2>/dev/null),)
    DOCKER_COMPOSE := docker-compose
else
    DOCKER_COMPOSE := docker compose
endif

install:
	$(DOCKER_COMPOSE) up -d

remove:
	@chmod +x confirm_remove.sh
	@./confirm_remove.sh

start:
	$(DOCKER_COMPOSE) start
startAndBuild: 
	$(DOCKER_COMPOSE) up -d --build

stop:
	$(DOCKER_COMPOSE) stop

update:
	# Calls the LLM update script
	chmod +x update_ollama_models.sh
	@./update_ollama_models.sh
	@git pull
	$(DOCKER_COMPOSE) down
	# Make sure the ollama-webui container is stopped before rebuilding
	@docker stop open-webui || true
	$(DOCKER_COMPOSE) up --build -d
	$(DOCKER_COMPOSE) start

lm-prepare:
	docker buildx create --name openwebui-builder

VERSION := $(shell git rev-parse --short HEAD)

lm:
	docker buildx build --builder openwebui-builder \
	--platform linux/amd64,linux/arm64 \
	-t registry.lazycat.cloud/open-webui:$(VERSION) \
	-t registry.lazycat.cloud/open-webui:latest \
	--push .

lm-post:
	docker buildx rm openwebui-builder