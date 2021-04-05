local docker = import '../../utils/docker.libsonnet';
local factory = import '../../utils/container-factory.libsonnet';
local utils = import '../../utils/utils.libsonnet';

local getDatabaseDependency(dependencies) =
  std.filterMap(function(x) x.type == "postgres", function(x) x, dependencies)[0];

{
  create(settings): 
    local databaseSettings = getDatabaseDependency(settings.dependencies);
    docker.container.new({
      name: settings.name,
      image: "jboss/keycloak:12.0.4",
      ports: [
        docker.port.different(settings.port, "8080"),
      ],
      restart: "always",
      depends_on: [
        databaseSettings.target
      ],
      environment: {
        DB_VENDOR: "POSTGRES",
        DB_ADDR: databaseSettings.target,
        DB_PORT: 5432,
        DB_DATABASE: databaseSettings.databases[0].name,
        DB_USER: databaseSettings.databases[0].users[0].name,
        DB_PASSWORD: databaseSettings.databases[0].users[0].password,
        KEYCLOAK_USER: settings.credentials[0],
        KEYCLOAK_PASSWORD: settings.credentials[1],
      }
    }),

  createAuxiliaryContainers(containerSettings, globalSettings): [],

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