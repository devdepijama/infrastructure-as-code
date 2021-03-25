local propertyByNameRecursive(properties, args) = 
    local size = std.length(args);
    if size == 1 then properties[args[0]] else propertyByNameRecursive(properties[args[0]], args[1:size:1]);

{
    get(properties, name): propertyByNameRecursive(properties, std.split(name, '.'))
}