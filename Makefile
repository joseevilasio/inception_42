NAME = inception
COMPOSE = docker compose -f srcs/docker-compose.yml

all: $(NAME)

$(NAME):
	$(COMPOSE) build
	$(COMPOSE) up -d

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down --remove-orphans

fclean: clean
	$(COMPOSE) down -v --rmi all --remove-orphans

re: fclean all

.PHONY: all up down clean fclean re $(NAME)