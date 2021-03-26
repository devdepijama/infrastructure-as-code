#! /bin/bash

# Create build directory if it doesnt exist
BUILD_DIR=".build"
mkdir -p ${BUILD_DIR}

function toJson() {
    FILE=$1
    cat ${FILE} | yq eval -j
}

function toYaml() {
    FILE=$1
    cat ${FILE} | yq eval -P
}

# Temporary files
toJson "infra.yaml" > ${BUILD_DIR}/settings.libsonnet

jsonnet infra.jsonnet > ${BUILD_DIR}/"docker-compose.json"
toYaml ${BUILD_DIR}/"docker-compose.json" > docker-compose.yaml