#! /bin/bash

echo "Configuring following MySQL server: ${MYSQL_HOST}:${MYSQL_PORT}..."

run_query () {
  QUERY=$1
  mysql -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} --host "${MYSQL_HOST}" --port "${MYSQL_PORT}" -e "${QUERY}" > /dev/null
}

for databaseRow in $(echo "${MYSQL_SETUP_INSTRUCTIONS}" | jq -c '.[]'); do
    DATABASE=$(echo "${databaseRow}" | jq -r '.name')

    echo "Creating ${DATABASE} database..."
    run_query "CREATE DATABASE ${DATABASE};"

    for userRow in $(echo "${databaseRow}" | jq -c '.users[]'); do
      USER=$(echo "${userRow}" | jq -r '.name')
      PASS=$(echo "${userRow}" | jq -r '.password')

      echo "Creating ${USER} user..."
      run_query "CREATE USER '${USER}'@'%' IDENTIFIED BY '${PASS}';"
      run_query "GRANT ALL PRIVILEGES ON ${DATABASE}.* TO '${USER}'@'%';"
    done
done