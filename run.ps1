Write-Host "Retriving kafka bootstrap service name"
$khost=$(oc get svc -l "app=cp-kafka" -o jsonpath="{.items[0].metadata.name}")
$kport=$(oc get svc -l "app=cp-kafka" -o jsonpath="{.items[0].spec.ports[0].port}")
$kafka=$khost + ":" + $kport
Write-Host Kafka service is at $kafka

# Create kafka-client
oc apply -f ../kafka-client.yaml

# Create perf testing topic
oc exec -it kafka-client -- kafka-topics --bootstrap-server $kafka --create --topic ssl-perf-test --partitions 6 --replication-factor 3 --config retention.ms=1800000 --config min.insync.replicas=2 --command-config /etc/kafka/config/client.properties

###########################################################################################

Write-Host "Ruuning Tests....."
# start producer
Write-Host "Test 1: Single producer throughput using TLS."
oc apply -f single-producer.yaml

# print logs
$producer=$(kubectl get pods --selector=job-name=kafka-single-producer-client --output=jsonpath='{.items[*].metadata.name}')
oc logs -f $producer

###########################################################################################

Write-Host "Test 2: Multiple producer throughput using TLS."
# start producer
oc apply -f multiple-producer.yaml

## conolidate logs from Test 1 and 2, using python script provided here.
## Make sure you have python and oc client installed in the system and PATH configured.
## Logs will be parsed to excel tables and saved to 'logs-summary[TS].xlsx'
python logParser.py

###########################################################################################

Write-Host "Test 3: Single producer and consumer throughput using TLS"
# start consumer
oc apply -f consumer.yaml
oc apply -f producer-fixed-single.yaml

# print logs
$producer=$(kubectl get pods --selector=job-name=kafka-producer-fixed-single --output=jsonpath='{.items[*].metadata.name}')
oc logs -f $producer
$consumer=$(kubectl get pods --selector=job-name=kafka-consumer-client --output=jsonpath='{.items[*].metadata.name}')
oc logs -f $consumer

###########################################################################################

Write-Host "Test 4: Multiple producer and single consumer throughput using TLS"
# start consumer
oc apply -f consumer-fixed-single.yaml
oc apply -f producer-fixed-multiple.yaml

# print logs
$producer=$(kubectl get pods --selector=job-name=kafka-producer-fixed-multiple --output=jsonpath='{.items[*].metadata.name}')
oc logs -f $producer
$consumer=$(kubectl get pods --selector=job-name=kafka-consumer-fixed-single --output=jsonpath='{.items[*].metadata.name}')
oc logs -f $consumer

###########################################################################################

Write-Host "Test 5: End to End Latency using TLS"
# start e2e latency testing
oc apply -f e2e.yaml
# print logs
$e2e=$(kubectl get pods --selector=job-name=kafka-e2e-client --output=jsonpath='{.items[*].metadata.name}')
oc logs -f $e2e

###########################################################################################
