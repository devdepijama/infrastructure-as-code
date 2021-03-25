for databaseRow in $(echo "${MONGO_SETUP_INSTRUCTIONS}" | jq -c '.[]'); do
    DATABASE=$(echo "${databaseRow}" | jq -r '.name')

    echo "Creating ${DATABASE} database..."

    for userRow in $(echo "${databaseRow}" | jq -c '.users[]'); do
      USER=$(echo "${userRow}" | jq -r '.name')
      PASS=$(echo "${userRow}" | jq -r '.password')

      echo "Creating ${USER} user..."
      mongo admin --host ${MONGO_HOST} --port ${MONGO_PORT} -u ${MONGO_ROOT_USER} -p ${MONGO_ROOT_PASSWORD} --eval "db.getSiblingDB('${DATABASE}').active.count; db.createUser({user: '${USER}', pwd: '${PASS}', roles: ['readWrite']})"
    done
done