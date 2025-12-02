FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive

RUN rm -f /etc/apt/sources.list.d/debian.sources && \
	printf "Types: deb\nURIs: http://deb.debian.org/debian\nSuites: bookworm bookworm-updates\nComponents: main contrib non-free\n" \
	> /etc/apt/sources.list.d/debian.sources

RUN apt-get update && \
	apt-get install -y mariadb-server && \
	rm -rf /var/lib/apt/lists/*

COPY conf/database.cnf /etc/mysql/mariadb.conf.d/database.cnf

COPY /tools/entrypoint.sh /tools/entrypoint.sh
RUN chmod +x /tools/entrypoint.sh

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/tools/entrypoint.sh"]