#!/bin/bash
#
# This does the job of mysql_secure_installation via queries that works
# better in a single-process Docker environment
#

secure_installation() {
    echo "Securing installation.."
    mysql -u root <<-EOF
    UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
    GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USERNAME' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
    CREATE DATABASE IF NOT EXISTS test;   
    CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE CHARACTER SET utf8;
    SOURCE /usr/share/mysql/innodb_memcached_config.sql;
    USE mysql;
    SOURCE /etc/mysql/zoneinfo.sql;
    install plugin daemon_memcached soname "libmemcached.so";
EOF
}

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "MYSQL_ROOT_PASSWORD not set";
    exit 1;
fi

if [ -z "$MYSQL_USERNAME" ]; then
    echo "MYSQL_USERNAME not set";
    exit 1;
fi

if [ -z "$MYSQL_PASSWORD" ]; then
    echo "MYSQL_PASSWORD not set";
    exit 1;
fi

if [ -z "MYSQL_DATABASE" ]; then
    echo "MYSQL_DATABASE not set";
    exit 1;
fi

echo "Setting up initial data"
mysql_install_db

echo "Starting mysql to setup privileges..."
/usr/sbin/mysqld &
MYSQL_TMP_PID=$!
echo "Sleeping for 5s"
sleep 5

# Try to connect as root without a password
mysql -u root <<-EOF
USE mysql;
EOF

if [ $? != 1 ]; then
    secure_installation
else
    echo "Error is OK, root password already set"
fi 

echo "Kill temporary mysql daemon"
kill -TERM $MYSQL_TMP_PID && wait

echo "Launching mysqld_safe"
/usr/bin/mysqld_safe
