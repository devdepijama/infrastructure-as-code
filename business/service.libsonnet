local docker = import '../utils/docker.libsonnet';
local factory = import '../utils/container-factory.libsonnet';

local DEPENDENCIES_FIELD = "dependencies";

{
  create(settings): docker.container.new(settings),
  addDependencies(builtContainer, containerSettings): builtContainer
}