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
      build: "./gateway/kong",
      ports: [
        docker.port.different(settings.ports.public, "8000"),
        docker.port.different(settings.ports.internal, "8001")
      ],
      restart: "always",
      depends_on: [
        databaseSettings.target
      ],
      environment: {
        KONG_PROXY_ACCESS_LOG: "/dev/stdout",
        KONG_ADMIN_ACCESS_LOG: "/dev/stdout",
        KONG_PROXY_ERROR_LOG: "/dev/stderr",
        KONG_ADMIN_ERROR_LOG: "/dev/stderr",
        KONG_PROXY_LISTEN: "0.0.0.0:8000",
        KONG_ADMIN_LISTEN: "0.0.0.0:8001",
        KONG_DATABASE: "postgres",
        KONG_PG_HOST: databaseSettings.target,
        KONG_PG_PORT: "5432",
        KONG_PG_DATABASE: databaseSettings.databases[0].name,
        KONG_PG_USER: databaseSettings.databases[0].users[0].name,
        KONG_PG_PASSWORD: databaseSettings.databases[0].users[0].password,
        KONG_PLUGINS: "oidc"
      }
    }),

  createAuxiliaryContainers(containerSettings, globalSettings): 
    local databaseSettings = getDatabaseDependency(containerSettings.dependencies);
    [
      docker.container.new({
        name: containerSettings.name + "-migrations-bootstrap",
        command: "kong migrations bootstrap",
        build: "./gateway/kong",
        restart: "on-failure",
        depends_on: [
          containerSettings.name + "-postgres-dependency"
        ],
        environment: {
          KONG_DATABASE: "postgres",
          KONG_PG_HOST: databaseSettings.target,
          KONG_PG_PORT: "5432",
          KONG_PG_DATABASE: databaseSettings.databases[0].name,
          KONG_PG_USER: databaseSettings.databases[0].users[0].name,
          KONG_PG_PASSWORD: databaseSettings.databases[0].users[0].password,
        }
      }),
      docker.container.new({
        name: containerSettings.name + "-migrations-up",
        command: "kong migrations up && kong migrations finish",
        build: "./gateway/kong",
        restart: "on-failure",
        depends_on: [
          containerSettings.name + "-postgres-dependency"
        ],
        environment: {
          KONG_DATABASE: "postgres",
          KONG_PG_HOST: databaseSettings.target,
          KONG_PG_PORT: "5432",
          KONG_PG_DATABASE: databaseSettings.databases[0].name,
          KONG_PG_USER: databaseSettings.databases[0].users[0].name,
          KONG_PG_PASSWORD: databaseSettings.databases[0].users[0].password,
        }
      })
    ],

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