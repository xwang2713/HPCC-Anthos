# -------------------
# Cluster information

# Use az, eksctl and gcloud to get AKS, EKS and GKE cluster names
#$clusters = @("eks-hpcc-1","aks-myhpcc-admin","gke-hpcc-1")
#$region_zones = @("us-east-1", "", "us-east1-b")
#$cluster_types = @("aws", "azure", "gcp")
#$storage_types = @("efs", "azure", "nfs")
$use_region = $false

$cluster_types = @("aws")
$clusters = @("eks-hpcc-1")
$region_zones = @("us-east-1")
$storage_types = @("efs")


# -------------------
# HPCC Platform deployment
$hpcc_namespace = "hpcc-system"
$hpcc_version = "community_7.10.6-1"
$hpcc_cluster_name = "hpcc-anthos-test"
$efs_id = "fs-739f91f3"

# -------------------
# Global Settings 
# Powershell Subsequent calls do not display UI.
$global:ProgressPreference = 'SilentlyContinue' 

# -------------------
# GCP Account
# To find out run: gcloud config get-value core/account
$GCP_EMAIL_ADDRESS = "xiaoming.wang@lexisnexis.com"
$USER_INITIAL = "xw"

# -------------------
# GCP Project 
# gcloud projects describe $PROJECT_ID
$PROJECT_ID = "anthos-hpcc-1"
$SERVICE_ACCOUNT_NAME = "svc-gke-cluster-1"
$LOCAL_KEY_PATH  = "$CREDS_DIR/${SERVICE_ACCOUNT_NAME}-${PROJECT_ID}.json"
$KUBECONFIG_PATH = "~/.kube/config"

# -------------------
# Directories

$BUILD_DIR = "${repo_parent_directory}/build"
if (!(Test-Path -path $BUILD_DIR))
{
   New-Item -ItemType directory -Path ${BUILD_DIR}
}

$CREDS_DIR = "${BUILD_DIR}/creds"
if (!(Test-Path -path $CREDS_DIR))
{
   New-Item -ItemType directory -Path ${CREDS_DIR}
}

$TOKEN_DIR = "${BUILD_DIR}/tokens"
if (!(Test-Path -path $TOKEN_DIR))
{
   New-Item -ItemType directory -Path ${TOKEN_DIR}
}

$DOWNLOAD_DIR = "${BUILD_DIR}/download"
if (!(Test-Path -path $DOWNLOAD_DIR))
{
   New-Item -ItemType directory -Path ${DOWNLOAD_DIR}
}

