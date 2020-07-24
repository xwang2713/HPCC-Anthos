# Use az, eksctl and gcloud to get AKS, EKS and GKE cluster names
#$clusters = "eks-hpcc-1","ks-myhpcc-admin","gks-hpcc-1"
$clusters = "eks-hpcc-1"

$GCP_EMAIL_ADDRESS = "xiaoming.wang@lexisnexis.com"
$USER_INITIAL = "xw"

$PROJECT_ID = "anthos-hpcc-1"
$SERVICE_ACCOUNT_NAME = "svc-gke-cluster-1"
$CREDS_DIR = "${repo_parent_directory}/creds"
$LOCAL_KEY_PATH  = "$CREDS_DIR/${SERVICE_ACCOUNT_NAME}-${PROJECT_ID}.json"
$KUBECONFIG_PATH = "~/.kube/config"
$TOKEN_DIR = "${repo_parent_directory}/tokens"

