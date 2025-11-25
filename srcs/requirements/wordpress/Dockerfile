FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	php-fpm php-mysql php-gd php-mbstring php-xml \
	php-curl php-zip php-intl php-soap \
	wget mariadb-client unzip \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

WORKDIR /usr/src

RUN wget https://wordpress.org/wordpress-6.1.3.tar.gz \
	&& tar -xzvf wordpress-6.1.3.tar.gz \
	&& rm wordpress-6.1.3.tar.gz

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY /tools/entrypoint.sh /tools/entrypoint.sh
RUN chmod +x /tools/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/tools/entrypoint.sh"]