#!/bin/bash
set -e

echo ">> Checking if /var/www/html is empty …"
if [ ! -f /var/www/html/index.php ]; then
    mkdir -p /var/www/html
    cp -aT /usr/src/wordpress /var/www/html
    chown -R www-data:www-data /var/www/html
fi

# ensure /run/php exists
echo ">> ensure /run/php exists …"
if [ ! -d /run/php ]; then
    mkdir -p /run/php
    chown -R www-data:www-data /run/php
fi

echo ">> cd /var/www/html …"
cd /var/www/html

echo ">> wait database …"
until mysql -h"${DB_HOST%%:*}" -P"${DB_HOST##*:}" -u"$DB_USER" -p"$DB_PASSWORD" -e "SHOW DATABASES;" >/dev/null 2>&1; do
    echo -n "."
    sleep 2
done

echo ">> Generating wp-config.php …"
# Generate wp-config.php
if [ ! -f wp-config.php ]; then
    wp config create \
      --dbname="$DB_NAME" \
      --dbuser="$DB_USER" \
      --dbpass="$DB_PASSWORD" \
      --dbhost="$DB_HOST" \
      --allow-root
fi

echo ">> Installing WordPress …"
# Install Wordpress
if ! wp core is-installed --allow-root; then
    wp core install \
      --url="$WP_URL" \
      --title="$WP_TITLE" \
      --admin_user="$WP_ADMIN" \
      --admin_password="$WP_ADMIN_PASSWORD" \
      --admin_email="$WP_ADMIN_MAIL" \
      --allow-root
fi

# Adjust permissions
chown -R www-data:www-data wp-content
find wp-content -type d -exec chmod 755 {} \;
find wp-content -type f -exec chmod 644 {} \;

echo ">> starting PHP-FPM <<"
exec php-fpm7.4 -F
