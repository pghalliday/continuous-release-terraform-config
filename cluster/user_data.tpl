#!/bin/bash

set -e

cluster="${cluster_name}"
region="${aws_region}"
task_definition="${task_definition}"

echo ECS_CLUSTER=$cluster >> /etc/ecs/ecs.config
start ecs

yum install -y aws-cli

instance_id=$(curl -s http://localhost:51678/v1/metadata | python -c 'import sys, json; print json.load(sys.stdin)["ContainerInstanceArn"]')


cat << EOF > /etc/init/consul-registrator.conf
description "consul-registrator"

start on started ecs

script
  aws ecs start-task --cluster $cluster --task-definition $task_definition --container-instances $instance_id --region $region
end script
EOF

initctl start consul-registrator
