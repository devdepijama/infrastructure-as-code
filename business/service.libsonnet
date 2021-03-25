local docker = import '../utils/docker.libsonnet';

/*
  Settings
  {
    "name": "my-java-service",
    "ports": [
        8080:8080,
        8081:8081
    ]
    "build": "./path/to/dockerfile/folder",
    "image": "imageName"
    "environment" : {
        "propertyA" : "valueOfA",
        "propertyB" : "valueOfB"
    },
  }
*/

{
  create(settings): docker.container.new(settings)
}