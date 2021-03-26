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

  createSetupContainer(dependantContainer, targetContainer, dependencySettings): 
    docker.container.new({
      name: getSetupContainerName(dependantContainer.name, targetContainer.name),
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

  addDependencies(buildContainer, containerSettings): buildContainer
}