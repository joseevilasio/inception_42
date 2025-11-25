#!/bin/bash
set -e

# Load secrets & environment variables

DB_PASSWORD="$(cat /run/secrets/db_password)"
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
WP_ADMIN_PASSWORD="$(cat /run/secrets/credentials)"

echo ">> Starting WordPress entrypoint..."
echo ">> Using database host: ${DB_HOST}"
echo ">> Using database: ${DB_NAME}"
echo ">> Using DB user: ${DB_USER}"

# Ensure /var/www/html exists and populate WordPress if empty

echo ">> Checking if /var/www/html is empty…"
if [ ! -f /var/www/html/index.php ]; then
    echo ">> Copying WordPress core files to /var/www/html…"
    mkdir -p /var/www/html
    cp -aT /usr/src/wordpress /var/www/html
    chown -R www-data:www-data /var/www/html
else
    echo ">> WordPress core already present."
fi

# Ensure /run/php exists

echo ">> Ensuring /run/php exists…"
mkdir -p /run/php
chown -R www-data:www-data /run/php

# Wait for MariaDB to respond BEFORE doing anything

echo ">> Waiting for MariaDB to be ready (mysqladmin ping)…"

# Extract host and port from DB_HOST
DB_HOSTNAME="${DB_HOST%%:*}"
DB_PORT="${DB_HOST##*:}"

# Timeout of 60 seconds
MAX_ATTEMPTS=60
ATTEMPT=0

until mysqladmin ping -h"${DB_HOSTNAME}" -P"${DB_PORT}" --silent; do
    ATTEMPT=$((ATTEMPT+1))
    echo -n "."
    if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
        echo ""
        echo "‼️ ERROR: MariaDB did not respond after ${MAX_ATTEMPTS} attempts."
        echo "Exiting."
        exit 1
    fi
    sleep 1
done

echo ""
echo ">> MariaDB is UP!"

# Generate wp-config.php if it does not exist

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo ">> Generating wp-config.php with WP-CLI…"
    wp config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST" \
        --allow-root
else
    echo ">> wp-config.php already exists."
fi

# Inject WP_HOME and WP_SITEURL if not present

if ! grep -q "WP_HOME" wp-config.php; then
    echo ">> Injecting WP_HOME and WP_SITEURL into wp-config.php…"
    sed -i "/<?php/a \
define('WP_HOME', '${WP_URL}');\n\
define('WP_SITEURL', '${WP_URL}');" wp-config.php
fi

# Install WordPress if not installed

echo ">> Installing WordPress (if needed)…"
if ! wp core is-installed --allow-root; then
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_MAIL" \
        --allow-root
else
    echo ">> WordPress already installed."
fi


echo ">> Fixing permissions…"
chown -R www-data:www-data wp-content
find wp-content -type d -exec chmod 755 {} \;
find wp-content -type f -exec chmod 644 {} \;

echo ">> Starting PHP-FPM in foreground"
exec php-fpm8.2 -F
