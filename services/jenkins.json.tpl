[
  {
    "volumesFrom": [],
    "memory": 128,
    "extraHosts": null,
    "dnsServers": null,
    "disableNetworking": true,
    "dnsSearchDomains": null,
    "portMappings": [],
    "hostname": null,
    "essential": false,
    "entryPoint": null,
    "mountPoints": [],
    "name": "jenkins-data",
    "ulimits": null,
    "dockerSecurityOptions": null,
    "environment": [],
    "links": null,
    "workingDirectory": null,
    "readonlyRootFilesystem": null,
    "image": "${replace(jenkins_data_url, "https://", "")}:latest",
    "command": [
      "echo hello"
    ],
    "user": null,
    "dockerLabels": null,
    "logConfiguration": null,
    "cpu": 0,
    "privileged": null,
    "memoryReservation": null
  },
  {
    "volumesFrom": [
      {
        "readOnly": null,
        "sourceContainer": "jenkins-data"
      }
    ],
    "memory": 500,
    "extraHosts": null,
    "dnsServers": null,
    "disableNetworking": null,
    "dnsSearchDomains": null,
    "portMappings": [
      {
        "hostPort": 8080,
        "containerPort": 8080,
        "protocol": "tcp"
      },
      {
        "hostPort": 50000,
        "containerPort": 50000,
        "protocol": "tcp"
      }
    ],
    "hostname": null,
    "essential": true,
    "entryPoint": null,
    "mountPoints": [],
    "name": "jenkins",
    "ulimits": null,
    "dockerSecurityOptions": null,
    "environment": [],
    "links": null,
    "workingDirectory": null,
    "readonlyRootFilesystem": null,
    "image": "${replace(jenkins_data_url, "https://", "")}:latest",
    "command": null,
    "user": null,
    "dockerLabels": null,
    "logConfiguration": null,
    "cpu": 0,
    "privileged": null,
    "memoryReservation": null
  }
]
