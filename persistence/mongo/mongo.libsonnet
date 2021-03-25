local docker = import '../../utils/docker.libsonnet';

local MONGO_IMAGE = "mongo";
local MONGO_DEFAULT_PORT = "27017";

local getDependencyName(containerName, targetName) =
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

  handleDependency(dependantContainer, targetContainer, dependencySettings): 
  local containerName = getDependencyName(dependantContainer.name, targetContainer.name);
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
  })
}