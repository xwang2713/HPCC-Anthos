# HPCC-Anthos

## Prerequisities
- Kubernetes server version 1.16
- Python 3.7 (GCSDK may not support 3.8 yet)
- GCSDK version 


## Get cluster information


### Google GKE
```console
gcloud container clusters get-credentials --zone <Zone> <GKE cluster name>
```
### AWS EKS
```console
aws eks --region <region> update-kubeconfig --name <EKS Cluber Name>
```
Edit ~/kube/config: in "Contexts" section find the EKS context and change "name" field to a shorter name (make it only contains aA-zA,0-9, -,_). For example, if the name is "arn:aws:eks:us-east-1:446598291512:cluster/eks-hpcc-1" change it to "eks-hpcc-1"

### Azure AKS
```console
az aks get-credentials --resource-group <resource group name> --name <AKS cluster name> --admin
```

## Prepare bin/env.ps1
If you use Lexisnexis system beware to process GKE clusters you need turn off vpn. But for AWS clusters you need turn vpn on. So probably you need process these two separately. For Azure clusters seems it doesn't matter use vpn or not.

Add above cluster names to bin/env.ps1 array $clusters
Set the cluster is GKE ($true or $false) in array $cluster_is_gke. Only Google GKE need to be set to "$true". GKE for AWS and on-premise should be set to "false".
For GKE cluster set the zone of the cluster in $zones. Other cluster can leave it as empty string.
Add your GCP user email to $GCP_EMAIL_ADDRESS
Add your user name initial to $USER_INITIAL

## Setup and Configure Anthos
```console
./bin/setup.ps1  (I didn't fully test this)
```


## register clusters
```console
./register-clusters.ps1
```
## Install Config Management
```console
./bin/install-config-management.ps1
```

## Install istio (Service Mesh)
```console
./bin/install-istio.ps1
```

## Install HPCC Cluster
Be aware only "default" namespace is supported for GKE
Also use HPCC Docker Cluster hpccsystems/platform-core:pilot-agent and Helm chart from github github.com/xwang2713/HPCC-Platform branch pilog-agent
```console
./bin/install-hpcc.ps1
```

## Monitoring
### GKE cluster
From Google Cloud console, go to "Monitoring"/"Service", click "DEFINE SERVICE", select eclwatch entry and click "SUBMIT". This service will show in Anthos Service Mesh dashboard.

### Non GKE cluster
Following istio/README.md to setup Grafana, Kiali, Prometheus monitorings

## Logging
### GKE cluster

### Non GKE cluster
There are "fluentd-elasticsearch" pod installed on each Kubernetes node. User can install related third party components to collect the log data.
Grafana, Kiali and Prometheus also provie logging which can be configured in above Monitoring section

## Uninstall HPCC Cluster
```console
./bin/uninstall-hpcc.ps1
```

## Unregister clusters
```console
./bin/unregister-clusters.ps1
```

## Migration
