#! /bin/bash

/scripts/wait-for-it.sh "$MYSQL_HOST:$MYSQL_PORT" -- /scripts/run.sh