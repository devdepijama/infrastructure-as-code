FROM mysql:5.7
ADD scripts /scripts
CMD "chmod a+x /scripts/*.sh"

RUN ["sh", "-c", "apt update && apt install -y jq"]

ENTRYPOINT [ "/scripts/entrypoint.sh" ]