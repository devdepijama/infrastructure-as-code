local builder = import './utils/builder.libsonnet';

# Auto-generated
local settings = import './.build/settings.libsonnet';

# Enrich name
local enrich(settings, fields) = 
    local size = std.length(fields);
    local field = fields[0];
    local sum = {
      [field] : {
          name: field
      }
      +
      settings[field]
    };
    if size == 1 then 
      sum
    else 
      sum + enrich(settings, fields[1:size:1]);

local enrichedSettings = enrich(settings, std.objectFields(settings));

local buildDynamically(settings, containers) = 
  {
    [std.objectFields(entry)[0]]: entry[std.objectFields(entry)[0]],
    for entry in std.flattenArrays(
      [
        builder.build(settings[container], settings)
        for container in containers
      ]
    )
  };

{
  version: "3",
  services: buildDynamically(enrichedSettings, std.objectFields(enrichedSettings))
}