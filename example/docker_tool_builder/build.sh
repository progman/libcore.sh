#!/bin/bash


export DOCKER_BUILDER_TMP_IMAGE="hello_image";
export DOCKER_BUILDER_TMP_CONTAINER="hello_builder";
export DOCKER_BUILDER_TARGET_FILE="/app/hello";


docker_tool_builder.sh;
if [ "${?}" != "0" ];
then
  exit 1;
fi


echo "ok, file ${DOCKER_BUILDER_TARGET_FILE} is ready";


exit 0;
