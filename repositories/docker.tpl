#!/bin/bash

set -e

$(aws ecr get-login --region ${aws_region})
docker build -t ${container} ./${container}
REPOSITORY=__REPOSITORY__
docker tag ${container}:latest $REPOSITORY:latest
docker push $REPOSITORY:latest
