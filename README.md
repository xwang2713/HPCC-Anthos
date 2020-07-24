# HPCC-Anthos

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
Add above cluster names to bin/env.ps1 variable $clusters
Add your GCP user email to $GCP_EMAIL_ADDRESS
Add your user name initial to $USER_INITIAL

## Setup and Configure Anthos
./bin/setup.ps1  (I didn't fully test this)
./register-clusters.ps1 (tested with AWS EKS)
