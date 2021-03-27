local docker = import '../../utils/docker.libsonnet';

local MONGO_IMAGE = "mongo";
local MONGO_DEFAULT_PORT = "27017";

local getSetupContainerName(containerName, targetName) =
  containerName + "-" + targetName + "-dependency";

{
  create(settings): docker.container.new({
    name: settings['name'],
    image: MONGO_IMAGE,
    ports: [
      docker.port.different(settings['port'], MONGO_DEFAULT_PORT)
    ],
    restart: "always",
    environment: {
        MONGO_INITDB_ROOT_USERNAME: settings['credentials'][0],
        MONGO_INITDB_ROOT_PASSWORD: settings['credentials'][1],
      },
    volumes: [
      docker.volume.new(settings['volume'], "/data/db")
    ]
  }),

  createSetupContainer(dependantContainer, targetContainer, dependencySettings): 
    local containerName = getSetupContainerName(dependantContainer.name, targetContainer.name);
    docker.container.new({
      name: containerName,
      build: "./persistence/mongo",
      environment: {
        MONGO_HOST: targetContainer.name,
        MONGO_PORT: targetContainer.port,
        MONGO_ROOT_USER: targetContainer.credentials[0],
        MONGO_ROOT_PASSWORD: targetContainer.credentials[1],
        MONGO_SETUP_INSTRUCTIONS: std.toString(dependencySettings.databases)
      },
      depends_on: [targetContainer.name]
    }),

  addDependencies(builtContainer, containerSettings, globalSettings): builtContainer,

  getDependenciesVars(targetContainer, dependencySettings):
    local prefix = std.asciiUpper(dependencySettings.name) + "_";
    local fixedProperties = {
        [prefix + "MONGO_HOST"]: targetContainer.name,
        [prefix + "MONGO_PORT"]: targetContainer.port
    };

    local databases = {
        [prefix + "MONGO_DATABASE_" + std.asciiUpper(database.name)] : database.name
        for database in dependencySettings.databases
    };

    local database_users = {
        [prefix + "MONGO_DATABASE_" + std.asciiUpper(database.name) + "_USER"]: credential.name
        for database in dependencySettings.databases
        for credential in database.users
    };

    local database_pass = {
        [prefix + "MONGO_DATABASE_" + std.asciiUpper(database.name) + "_PASSORD"]: credential.password
        for database in dependencySettings.databases
        for credential in database.users
    };

    fixedProperties + databases + database_users + database_pass
}