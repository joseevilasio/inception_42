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
	- docker stop $$(docker ps -qa)
	- docker rm $$(docker ps -qa)
	- docker rmi -f $$(docker images -qa)
	- docker volume rm $$(docker volume ls -qa)
	- docker network rm $$(docker network ls -qa) 2>/dev/null

re: fclean
	$(MAKE) all

.PHONY: all up clean fclean re $(NAME)