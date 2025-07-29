FROM debian:bullseye

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	php7.4-fpm php7.4-mysql php7.4-gd php7.4-mbstring php7.4-xml \
	wget mariadb-client \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

WORKDIR /usr/src

RUN wget https://wordpress.org/wordpress-6.1.3.tar.gz \
	&& tar -xzvf wordpress-6.1.3.tar.gz \
	&& rm wordpress-6.1.3.tar.gz

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY /tools/entrypoint.sh /tools/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/tools/entrypoint.sh"]