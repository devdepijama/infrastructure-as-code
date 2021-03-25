local mutualExclusiveFields(settings, fieldA, fieldB, mandatory = true) = 
    if std.objectHas(settings, fieldA) then 
        {[fieldA]: settings[fieldA]}
    else if std.objectHas(settings, fieldB) then
        {[fieldB]: settings[fieldB]}
    else if [mandatory == false] then
        {}
    else
        error "Neither " + fieldA + " or " + fieldB + " specified";

local optionalField(settings, field) = 
    if std.objectHas(settings, field) then 
        {[field]: settings[field]}
    else 
        {};

local buildContainer(settings) = {
    [settings['name']]: {
        container_name: settings['name']
    }
    + optionalField(settings, "ports")
    + optionalField(settings, "restart")
    + optionalField(settings, "environment")
    + optionalField(settings, "volumes")
    + optionalField(settings, "depends_on")
    + mutualExclusiveFields(settings, "build", "image")
};

{
    port: {
        same(port): port + ":" + port,
        different(host, container): host + ":" + container
    },
    volume: {
        new(pathOnHost, pathOnContainer): pathOnHost + ":" + pathOnContainer
    },
    container: {
        new(settings) : buildContainer(settings)
    },
}