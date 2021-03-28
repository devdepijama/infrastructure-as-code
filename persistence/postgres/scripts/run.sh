#! /bin/bash

echo "Configuring following Postgres server: ${POSTGRES_HOST}:${POSTGRES_PORT}..."
echo "Setup instructions: ${POSTGRES_SETUP_INSTRUCTIONS}"

run_query () {
  QUERY=$1
  psql --command="${QUERY}" "postgresql://${POSTGRES_ROOT_USER}:${POSTGRES_ROOT_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/default" >> /dev/null
}

for databaseRow in $(echo "${POSTGRES_SETUP_INSTRUCTIONS}" | jq -c '.[]'); do
    DATABASE=$(echo "${databaseRow}" | jq -r '.name')

    echo "Creating ${DATABASE} database..."
    run_query "CREATE DATABASE ${DATABASE};" 

    for userRow in $(echo "${databaseRow}" | jq -c '.users[]'); do
      USER=$(echo "${userRow}" | jq -r '.name')
      PASS=$(echo "${userRow}" | jq -r '.password')

      echo "Creating ${USER} user..."
      run_query "CREATE USER ${USER} WITH PASSWORD '${PASS}';"
    done
done
