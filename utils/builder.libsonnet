local factory = import 'container-factory.libsonnet';

local buildContainer(containerSettings) = 
    factory[containerSettings['type']].create(containerSettings);

local mapDependency(dependency, containerSettings, globalSettings) =
    factory[dependency.type].createSetupContainer(
        containerSettings, 
        globalSettings[dependency.target],
        dependency
    );

local buildSetupContainers(containerSettings, globalSettings) = 
    local hasDependencies = std.objectHas(containerSettings, "dependencies");

    if hasDependencies then
        std.map(
            function(dependency) mapDependency(dependency, containerSettings, globalSettings), 
            containerSettings.dependencies
        )
    else
        [];


local enrichWithEnvVars(builtContainer, containerSettings) =
    factory[containerSettings['type']].addDependencies(builtContainer, containerSettings);

{
    build(containerSettings, globalSettings): 
        std.flattenArrays(
            [
                [enrichWithEnvVars(buildContainer(containerSettings), containerSettings)], 
                buildSetupContainers(containerSettings, globalSettings)
            ]
        )
}