local factory = import 'container-factory.libsonnet';

local DEPENDENCIES_FIELD = "dependencies";

local buildContainer(containerSettings) = 
    factory[containerSettings['type']].create(containerSettings);

local buildSetupContainers(containerSettings, globalSettings, dependencies) = 
    local size = std.length(dependencies);
    local dependency = dependencies[0];
    local entry = factory[dependency.type].createSetupContainer(
        containerSettings, 
        globalSettings[dependency.target],
        dependency
    );

    if size == 1 then 
        entry
    else 
        entry + buildSetupContainers(containerSettings, globalSettings, dependencies[1:size:1]);

local buildSetupContainersBegin(containerSettings, globalSettings) = 
    local hasDependencies = std.objectHas(containerSettings, DEPENDENCIES_FIELD);

    if hasDependencies then
        buildSetupContainers(containerSettings, globalSettings, containerSettings[DEPENDENCIES_FIELD])
    else
        {};

local enrichWithEnvVars(builtContainer, containerSettings) =
    factory[containerSettings['type']].addDependencies(builtContainer, containerSettings);

{
    build(containerSettings, globalSettings): 
        enrichWithEnvVars(buildContainer(containerSettings), containerSettings) +
        buildSetupContainersBegin(containerSettings, globalSettings)
}