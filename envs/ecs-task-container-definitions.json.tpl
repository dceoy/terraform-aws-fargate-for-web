[
  {
    "name": "${name}",
    "image": "${image}",
    "versionConsistency": "enabled",
    "essential": true,
    "readonlyRootFilesystem": false,
    "environment": [
      {
        "name": "SYSTEM_NAME",
        "value": "${system-name}"
      },
      {
        "name": "ENV_TYPE",
        "value": "${env-type}"
      }
    ],
    "portMappings": [
      {
        "containerPort": ${port-mapping-container-port},
        "hostPort": ${port-mapping-host-port},
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${awslogs-region}",
        "awslogs-group": "${awslogs-group}",
        "awslogs-stream-prefix": "${name}"
      }
    },
    "restartPolicy": {
        "enabled": true,
        "ignoredExitCodes": [0],
        "restartAttemptPeriod": ${restart-attempt-period}
    }
  }
]
