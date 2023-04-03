kubectl scale statefulsets edge-artifactory --replicas=0
kubectl scale statefulsets insight --replicas=0
kubectl scale statefulsets xray-rabbitmq --replicas=0
kubectl scale statefulsets xray --replicas=0
kubectl scale statefulsets distribution --replicas=0
kubectl scale statefulsets artifactory --replicas=0
kubectl scale deployment edge-artifactory-nginx --replicas=0
kubectl scale deployment artifactory-artifactory-nginx --replicas=0
