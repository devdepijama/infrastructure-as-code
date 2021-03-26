local docker = import '../utils/docker.libsonnet';


{
  create(settings): docker.container.new(settings)
}