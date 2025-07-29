NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml

$(NAME):
	$(COMPOSE) build
	$(COMPOSE) up -d

all: $(NAME)

up:
	$(COMPOSE) up -d

clean:
	$(COMPOSE) compose down

fclean:
	- docker stop $$(docker ps -qa) 2>/dev/null || true
	- docker rm $$(docker ps -qa) 2>/dev/null || true
	- docker rmi -f $$(docker images -qa) 2>/dev/null || true
	- docker volume rm $$(docker volume ls -qa) 2>/dev/null || true
	- docker network rm $$(docker network ls -q) 2>/dev/null || true

re: fclean
	$(MAKE) all

.PHONY: all up clean fclean re $(NAME)