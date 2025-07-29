FROM debian:bullseye

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
	apt-get install -y mariadb-server && \
	rm -rf /var/lib/apt/lists/*

COPY conf/database.cnf /etc/mysql/mariadb.conf.d/database.cnf

COPY /tools/entrypoint.sh /tools/entrypoint.sh

EXPOSE 3306

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/tools/entrypoint.sh"]