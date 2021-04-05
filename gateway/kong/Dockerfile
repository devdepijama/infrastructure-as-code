FROM kong:2.3.3-alpine

# Customization phase
USER root
RUN luarocks install kong-oidc

# Returning to default user access
USER kong