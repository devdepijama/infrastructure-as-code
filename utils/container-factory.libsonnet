local mysql = import '../persistence/mysql/mysql.libsonnet';
local mongo = import '../persistence/mongo/mongo.libsonnet';
local postgres = import '../persistence/postgres/postgres.libsonnet';

local kong = import '../gateway/kong/kong.libsonnet';

local service = import '../business/service.libsonnet';

{
    "mysql": mysql,
    "mongo": mongo,
    "service": service,
    "postgres": postgres,

    "kong": kong
}