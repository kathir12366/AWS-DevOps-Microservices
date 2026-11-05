#!/bin/bash
set -e

sql_escape() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\'/\'\'}
  printf '%s' "$value"
}

USER_PASSWORD_SQL=$(sql_escape "$MYSQL_USER_PASSWORD")
PRODUCT_PASSWORD_SQL=$(sql_escape "$MYSQL_PRODUCT_PASSWORD")
ORDER_PASSWORD_SQL=$(sql_escape "$MYSQL_ORDER_PASSWORD")

mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<SQL
CREATE DATABASE IF NOT EXISTS user_service;
CREATE DATABASE IF NOT EXISTS product_service;
CREATE DATABASE IF NOT EXISTS order_service;

CREATE USER IF NOT EXISTS 'user_service'@'%' IDENTIFIED BY '${USER_PASSWORD_SQL}';
GRANT ALL PRIVILEGES ON user_service.* TO 'user_service'@'%';

CREATE USER IF NOT EXISTS 'product_service'@'%' IDENTIFIED BY '${PRODUCT_PASSWORD_SQL}';
GRANT ALL PRIVILEGES ON product_service.* TO 'product_service'@'%';

CREATE USER IF NOT EXISTS 'order_service'@'%' IDENTIFIED BY '${ORDER_PASSWORD_SQL}';
GRANT ALL PRIVILEGES ON order_service.* TO 'order_service'@'%';

FLUSH PRIVILEGES;
SQL
