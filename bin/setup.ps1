# https://cloud.google.com/anthos/multicluster-management/connect/prerequisites?hl=en_US

$bin_directory  = Split-Path $myInvocation.MyCommand.path
$root_directory = Split-Path -Path ${bin_directory} -Parent
$repo_parent_directory = Split-Path -Path ${root_directory} -Parent

.  ${bin_directory}/env.ps1

#gcloud auth login
#gcloud components install beta

gcloud projects add-iam-policy-binding ${PROJECT_ID} `
 --member user:${GCP_EMAIL_ADDRESS} `
 --role=roles/gkehub.admin `
 --role=roles/iam.serviceAccountAdmin `
 --role=roles/iam.serviceAccountKeyAdmin `
 --role=roles/resourcemanager.projectIamAdmin

gcloud services enable `
 --project=${PROJECT_ID} `
 container.googleapis.com `
 gkeconnect.googleapis.com `
 gkehub.googleapis.com `
 cloudresourcemanager.googleapis.com `
 anthos.googleapis.com `
 meshca.googleapis.com `
 meshtelemetry.googleapis.com `
 meshconfig.googleapis.com `
 iap.googleapis.com 


gcloud projects add-iam-policy-binding ${PROJECT_ID} `
 --member user:${GCP_EMAIL_ADDRESS} `
 --role roles/gkehub.viewer `
 --role=roles/compute.viewer `
 --role=roles/container.viewer `
 --role=roles/monitoring.editor

gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} --project=${PROJECT_ID}
gcloud iam service-accounts list --project=${PROJECT_ID}

gcloud projects add-iam-policy-binding ${PROJECT_ID} `
 --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" `
 --role="roles/gkehub.connect"

gcloud iam service-accounts keys create ${LOCAL_KEY_PATH} `
  --iam-account=${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com `
  --project=${PROJECT_ID}

Check current Google Cloud user havae cluster-admin RBAC role by running:
kubectl auth can-i '*' '*' --all-namespaces



# Install nomos.exe
$nomos = ${repo_parent_directory}/nomos.exe 
if (!(Test-Path $nomos -PathType Leaf))
{
  gsutil cp gs://config-management-release/released/latest/windows_amd64/nomos.exe  $nomos
}
 

# install kpt
# gcloud components install kpt

# install kustomize
# choco install kustomize

# gcloud components install anthoscli beta
# gcloud components update


# ASM Mesh Data Plane Service Account
# gcloud projects get-iam-policy anthos-hpcc-1 | grep  'meshdataplane'
# should return "role: roles/meshdataplane.serviceAgent" and something. Otherwise following below
# Remove-item alias:curl
#curl --request POST `
#  --header "Authorization: Bearer $(gcloud auth print-access-token)" `
#  --data '' `
#  https://meshconfig.googleapis.com/v1alpha1/projects/${PROJECT_ID}:initialize
