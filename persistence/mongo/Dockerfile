FROM mongo
ADD scripts /scripts
CMD "chmod a+x /scripts/*.sh"

RUN ["sh", "-c", "apt-get update && apt-get install -y jq"]

ENTRYPOINT [ "/scripts/entrypoint.sh" ]