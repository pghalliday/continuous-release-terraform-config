#!/bin/bash

cluster="${cluster_name}"
region="${aws_region}"
task_definition="${task_definition}"

echo ECS_CLUSTER=$cluster >> /etc/ecs/ecs.config
start ecs

instance_arn=$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .ContainerInstanceArn' | awk -F/ '{print $NF}' )

cat << EOF > /etc/init/consul.conf
description "consul"

start on started ecs

script
  aws ecs start-task --cluster $cluster --task-definition $task_definition --container-instances $instance_arn --region $region
end script
EOF

initctl start consul
