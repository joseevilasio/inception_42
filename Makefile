NAME = inception

$(NAME): docker compose build
	docker compose up -d

all: $(NAME)

clean:
	docker compose down

fclean:
	docker stop $(docker ps -qa)
	docker rm $(docker ps -qa)
	docker rmi -f $(docker images -qa)
	docker volume rm $(docker volume ls -qa)
	docker network rm $(docker network ls -qa) 2>/dev/null

re: fclean
	$(MAKE) all

.PHONY: all clean fclean re