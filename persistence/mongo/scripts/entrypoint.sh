#! /bin/bash

/scripts/wait-for-it.sh "${MONGO_HOST}:${MONGO_PORT}" -- /scripts/run.sh