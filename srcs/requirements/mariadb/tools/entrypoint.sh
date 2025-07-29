#!/bin/bash
set -e

# Load environment variables
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASSWORD="${DB_PASSWORD}"

ADMIN_USER="${DB_ROOT_USER:-root}"
ADMIN_PASSWORD="${DB_ROOT_PASSWORD:-rootpass}"

DATADIR="/var/lib/mysql"

echo "[INFO] Starting MariaDB entrypoint..."
echo "[INFO] Data directory: $DATADIR"

# Ensure log directory exists (used in custom my.cnf)
mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

# Initialize database if not already initialized
if [ ! -d "$DATADIR/mysql" ]; then
    echo "[INFO] Database not found, initializing with mysql_install_db..."
    mysql_install_db --user=mysql --datadir="$DATADIR"

    echo "[INFO] Starting temporary MariaDB daemon..."
    mysqld_safe --datadir="$DATADIR" &
    sleep 5

    echo "[INFO] Creating database and users..."
    mysql -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

        CREATE USER IF NOT EXISTS '${ADMIN_USER}'@'%' IDENTIFIED BY '${ADMIN_PASSWORD}';
        GRANT ALL PRIVILEGES ON *.* TO '${ADMIN_USER}'@'%' WITH GRANT OPTION;

        FLUSH PRIVILEGES;
EOSQL

    echo "[INFO] Shutting down temporary MariaDB..."
    mysqladmin -u root shutdown
else
    echo "[INFO] Existing database found. Skipping initialization."
fi

echo "[INFO] Starting MariaDB in foreground..."
exec mysqld_safe --datadir="$DATADIR"
