local docker = import '../utils/docker.libsonnet';
local factory = import '../utils/container-factory.libsonnet';

local DEPENDENCIES_FIELD = "dependencies";

local arrayToObject(array) =
  local size = std.length(array);
  if size == 1 then
    array[0]
  else
    array[0] + arrayToObject(array[1:size]);

{
  create(settings): docker.container.new(settings),

  createAuxiliaryContainers(containerSettings, globalSettings): [],

  addDependencies(builtContainer, containerSettings, globalSettings): 
    self.create(
      containerSettings + {
        "environment": arrayToObject(
          std.map(
            function(dependency) factory[dependency.type].getDependenciesVars(globalSettings[dependency.target], dependency), 
            containerSettings.dependencies
          )
        )
      }
    )

}