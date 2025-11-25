#!/bin/bash
set -e

# Load environment variables
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASSWORD="$(cat /run/secrets/db_password)"

ADMIN_USER="${DB_ROOT_USER}"
ADMIN_PASSWORD="$(cat /run/secrets/db_root_password)"

DATADIR="/var/lib/mysql"

echo "[INFO] Starting MariaDB entrypoint..."
echo "[INFO] Data directory: $DATADIR"

# ensure mysqld socket dir exists ---
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Ensure log directory exists
mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

# Initialize database if not already initialized
if [ ! -d "$DATADIR/mysql" ]; then
    echo "[INFO] Database not found, initializing with mysql_install_db..."
    mysql_install_db --user=mysql --datadir="$DATADIR"

    echo "[INFO] Starting temporary MariaDB daemon..."
    mariadbd --user=mysql --datadir="$DATADIR" --skip-networking &
    TEMP_PID=$!

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
    kill "$TEMP_PID"
    wait "$TEMP_PID" 2>/dev/null || true

else
    echo "[INFO] Existing database found. Skipping initialization."
fi

echo "[INFO] Starting MariaDB in foreground..."
exec mariadbd --user=mysql --datadir="$DATADIR" --console
