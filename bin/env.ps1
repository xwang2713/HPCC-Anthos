# Use az, eksctl and gcloud to get AKS, EKS and GKE cluster names
#$clusters = @("eks-hpcc-1","aks-myhpcc-admin","gke-hpcc-1")
#$zones = @("", "", "us-east1-b")
#$cluster_is_gke = @($false, $false, $true)

$clusters = @("aks-myhpcc-admin")
$zones = @("")
$cluster_is_gke = @($false)
#$clusters = @("gke-hpcc-1")
#$zones = @("us-east1-b")
#$cluster_is_gke = @($true)

# Powershell Subsequent calls do not display UI.
$global:ProgressPreference = 'SilentlyContinue' 

# To find out run: gcloud config get-value core/account
$GCP_EMAIL_ADDRESS = "xiaoming.wang@lexisnexis.com"
$USER_INITIAL = "xw"

$PROJECT_ID = "anthos-hpcc-1"
# gcloud projects describe $PROJECT_ID
$SERVICE_ACCOUNT_NAME = "svc-gke-cluster-1"
$CREDS_DIR = "${repo_parent_directory}/creds"
if (!(Test-Path -path $CREDS_DIR))
{
   New-Item -ItemType directory -Path ${CREDS_DIR}
}

$LOCAL_KEY_PATH  = "$CREDS_DIR/${SERVICE_ACCOUNT_NAME}-${PROJECT_ID}.json"
$KUBECONFIG_PATH = "~/.kube/config"
$TOKEN_DIR = "${repo_parent_directory}/tokens"
if (!(Test-Path -path $TOKEN_DIR))
{
   New-Item -ItemType directory -Path ${TOKEN_DIR}
}

$DOWNLOAD_DIR = "${repo_parent_directory}/download"
if (!(Test-Path -path $DOWNLOAD_DIR))
{
   New-Item -ItemType directory -Path ${DOWNLOAD_DIR}
}

