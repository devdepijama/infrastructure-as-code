local docker = import '../../utils/docker.libsonnet';

local MYSQL_IMAGE = "mysql:5.7";
local MYSQL_DEFAULT_PORT = "3306";

local getSetupContainerName(containerName, targetName) =
  containerName + "-" + targetName + "-dependency";

{
  create(settings): docker.container.new({
    name: settings['name'],
    image: MYSQL_IMAGE,
    ports: [
      docker.port.different(settings['port'], MYSQL_DEFAULT_PORT)
    ],
    restart: "always",
    environment: {
      MYSQL_ROOT_PASSWORD: settings['credentials'][1]
    }
  }),

  createSetupContainer(dependentContainer, targetContainer, dependencySettings): 
    docker.container.new({
      name: getSetupContainerName(dependentContainer.name, targetContainer.name),
      build: "./persistence/mysql/",
      environment: {
        MYSQL_HOST: targetContainer.name,
        MYSQL_PORT: targetContainer.port,
        MYSQL_ROOT_USER: targetContainer.credentials[0],
        MYSQL_ROOT_PASSWORD: targetContainer.credentials[1],
        MYSQL_SETUP_INSTRUCTIONS: std.toString(dependencySettings.databases)
      },
      depends_on: [targetContainer.name]
    }),
  
  createAuxiliaryContainers(containerSettings, globalSettings): [],

  addDependencies(builtContainer, containerSettings, globalSettings): builtContainer,

  getDependenciesVars(targetContainer, dependencySettings):
    local prefix = std.asciiUpper(dependencySettings.name) + "_";
    local fixedProperties = {
        [prefix + "MYSQL_HOST"]: targetContainer.name,
        [prefix + "MYSQL_PORT"]: targetContainer.port
    };
    local databases = {
        [prefix + "MYSQL_DATABASE_" + std.asciiUpper(database.name)]: database.name
        for database in dependencySettings.databases
    };
    local database_users = {
        [prefix + "MYSQL_DATABASE_" + std.asciiUpper(database.name) + "_USER"]: credential.name
        for database in dependencySettings.databases
        for credential in database.users
    };
    local database_pass = {
        [prefix + "MYSQL_DATABASE_" + std.asciiUpper(database.name) + "_PASSWORD"]: credential.password
        for database in dependencySettings.databases
        for credential in database.users
    };
    
    fixedProperties + databases + database_users + database_pass
}