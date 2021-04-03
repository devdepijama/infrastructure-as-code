local propertyByNameRecursive(properties, args) = 
    local size = std.length(args);
    if size == 1 then properties[args[0]] else propertyByNameRecursive(properties[args[0]], args[1:size:1]);

{
    get(properties, name): propertyByNameRecursive(properties, std.split(name, '.'))
}

local arrayToObject(array) =
  local size = std.length(array);
  if size == 1 then
    array[0]
  else
    array[0] + arrayToObject(array[1:size]);