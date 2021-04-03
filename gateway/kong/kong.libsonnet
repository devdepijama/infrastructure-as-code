local docker = import '../../utils/docker.libsonnet';
local factory = import '../../utils/container-factory.libsonnet';
local utils = import '../../utils/utils.libsonnet';

{
  create(settings): docker.container.new({
    name: settings.name,
    image: "kong",
    ports: [
      docker.port.different(settings.ports.public, "8000"),
      docker.port.different(settings.ports.internal, "8001")
    ],
    restart: "always",
    environment: {
        KONG_DATABASE: "off",
        KONG_PROXY_ACCESS_LOG: "/dev/stdout",
        KONG_ADMIN_ACCESS_LOG: "/dev/stdout",
        KONG_PROXY_ERROR_LOG: "/dev/stderr",
        KONG_ADMIN_ERROR_LOG: "/dev/stderr",
        KONG_ADMIN_LISTEN: "0.0.0.0:8001"
    }
  }),

  addDependencies(builtContainer, containerSettings, globalSettings): 
    self.create(
        containerSettings + {
        "environment": utils.arrayToObject(
            std.map(
            function(dependency) factory[dependency.type].getDependenciesVars(globalSettings[dependency.target], dependency), 
            containerSettings.dependencies
            )
        )
        }
    )
}