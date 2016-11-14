#!/bin/bash

set -e

local_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

cat << EOF > /etc/init/consul.conf
description "consul"
start on filesystem and started docker
stop on runlevel [!2345]
respawn
script
  /usr/bin/docker run -d --net=host -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' consul agent -server -bind=$local_ip -client=$local_ip -ui -retry-join-ec2-tag-key=${ec2_tag_key} -retry-join-ec2-tag-value=${ec2_tag_value} -bootstrap-expect=${bootstrap_expect}
end script
EOF

initctl start consul
