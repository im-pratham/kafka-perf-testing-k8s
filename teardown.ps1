Write-Host "Getting list of the example resources created..."
oc get all -l "type=kafka-examples,app=kafka-examples" -o name

Write-Host "Deleting example resources created..."
oc delete all -l "type=kafka-examples,app=kafka-examples" -o name

Write-Host "Done. Happy Streaming!..."
