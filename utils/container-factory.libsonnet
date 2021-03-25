local mysql = import '../persistence/mysql/mysql.libsonnet';
local mongo = import '../persistence/mongo/mongo.libsonnet';
local service = import '../business/service.libsonnet';

{
    "mysql": mysql,
    "mongo": mongo,
    "service": service
}