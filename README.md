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
./bin/setup.ps1  (I didn't fully test this)
./register-clusters.ps1 (tested with AWS EKS)


## register clusters

## Install Config Management

## Install istio

## Unregister clusters
