# kafka-perf-testing-k8s
### Kafka Performance Testing Scripts

This directory contains various artefacts for doing performance testing of Kafka cluster.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `image` | Docker Image of Confluent Kafka. | `cp-server` |
| `imageTag` | Docker Image Tag of Confluent Kafka. | `7.0.1` |

## Prerequisites

Make sure you have following components installed and PATH variable is configured correctly.
- oc
- python (Optional, required for running logParser.py) (If not installed comment the line for log parsing in [perf-testing.ps1](./perf-testing.ps1))

## Running scripts
All testing scripts are bundled as K8S jobs. All commands required for running the tests are compiles in [perf-testing.ps1](./perf-testing.ps1).

## Cleaning up
You can clean up the resources created for testing using [teardown.ps1](./teardown.ps1)
