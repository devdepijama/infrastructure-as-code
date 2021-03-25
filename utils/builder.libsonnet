local factory = import 'container-factory.libsonnet';

local DEPENDENCIES_FIELD = "dependencies";

local buildContainer(containerSettings) = 
    factory[containerSettings['type']].create(containerSettings);

local buildDependencies(containerSettings, globalSettings, dependencies) = 
    local size = std.length(dependencies);
    local dependency = dependencies[0];
    local entry = factory[dependency.type].handleDependency(
        containerSettings, 
        globalSettings[dependency.target],
        dependency
    );

    if size == 1 then 
        entry
    else 
        entry + buildDependencies(containerSettings, globalSettings, dependencies[1:size:1]);

local buildDependenciesBegin(containerSettings, globalSettings) = 
    local hasDependencies = std.objectHas(containerSettings, DEPENDENCIES_FIELD);

    if hasDependencies then
        buildDependencies(containerSettings, globalSettings, containerSettings[DEPENDENCIES_FIELD])
    else
        {};

{
    build(containerSettings, globalSettings): 
        buildContainer(containerSettings) +
        buildDependenciesBegin(containerSettings, globalSettings)
}