#! /bin/bash

/scripts/wait-for-it.sh "${POSTGRES_HOST}:${POSTGRES_PORT}" -- /scripts/run.sh