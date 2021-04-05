local docker = import '../../utils/docker.libsonnet';

local POSTGRES_IMAGE = "postgres:9.5";
local POSTGRES_DEFAULT_PORT = "5432";

local getSetupContainerName(containerName, targetName) =
  containerName + "-" + targetName + "-dependency";

{
  create(settings): docker.container.new({
    name: settings['name'],
    image: POSTGRES_IMAGE,
    ports: [
      docker.port.different(settings['port'], POSTGRES_DEFAULT_PORT)
    ],
    restart: "always",
    environment: {
      POSTGRES_USER: settings.credentials[0],
      POSTGRES_PASSWORD: settings.credentials[1],
      POSTGRES_DB: "default"
    }
  }),

  createAuxiliaryContainers(containerSettings, globalSettings): [],

  createSetupContainer(dependentContainer, targetContainer, dependencySettings): 
    docker.container.new({
      name: getSetupContainerName(dependentContainer.name, targetContainer.name),
      build: "./persistence/postgres/",
      environment: {
        POSTGRES_HOST: targetContainer.name,
        POSTGRES_PORT: targetContainer.port,
        POSTGRES_ROOT_USER: targetContainer.credentials[0],
        POSTGRES_ROOT_PASSWORD: targetContainer.credentials[1],
        POSTGRES_SETUP_INSTRUCTIONS: std.toString(dependencySettings.databases)
      },
      depends_on: [targetContainer.name]
    }),

  addDependencies(builtContainer, containerSettings, globalSettings): builtContainer,

  getDependenciesVars(targetContainer, dependencySettings):
    local prefix = std.asciiUpper(dependencySettings.name) + "_";
    local fixedProperties = {
        [prefix + "POSTGRES_HOST"]: targetContainer.name,
        [prefix + "POSTGRES_PORT"]: targetContainer.port
    };
    local databases = {
        [prefix + "POSTGRES_DATABASE_" + std.asciiUpper(database.name)]: database.name
        for database in dependencySettings.databases
    };
    local database_users = {
        [prefix + "POSTGRES_DATABASE_" + std.asciiUpper(database.name) + "_USER"]: credential.name
        for database in dependencySettings.databases
        for credential in database.users
    };
    local database_pass = {
        [prefix + "POSTGRES_DATABASE_" + std.asciiUpper(database.name) + "_PASSWORD"]: credential.password
        for database in dependencySettings.databases
        for credential in database.users
    };
    
    fixedProperties + databases + database_users + database_pass
}