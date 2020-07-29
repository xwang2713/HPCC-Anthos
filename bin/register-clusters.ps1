# https://cloud.google.com/anthos/multicluster-management/connect/registering-a-cluster?hl=en_US#before_you_begin

$bin_directory  = Split-Path $myInvocation.MyCommand.path
$root_directory = Split-Path -Path ${bin_directory} -Parent
$repo_parent_directory = Split-Path -Path ${root_directory} -Parent
$config_directory = "${root_directory}/config"

.  ${bin_directory}/env.ps1

#gcloud iam service-accounts list

for ( $i=0; $i -lt $clusters.length;  $i++)
{
   $cluster = $clusters[$i]
   echo "Register cluster: $cluster"
   kubectl config use-context $cluster 
   if ($cluster_types[$i] -eq "gcp")
   {
     $region_zone = $region_zones[$i]
     $PROJECT_NUMBER = $(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
     $Env:PROJECT_NUMBER = ${PROJECT_NUMBER}
     $Env:CLUSTER_NAME = ${cluster}
     $Env:CLUSTER_LOCATION = ${region_zone}
     $Env:WORKLOAD_POOL = "${PROJECT_ID}.svc.id.goog"
     $Env:MESH_ID = "proj-${PROJECT_NUMBER}"
 
     if ($use_region)
     {
       gcloud config set compute/region ${region_zone} # not support yet
     }
     else
     {
       gcloud config set compute/zone ${region_zone}
     }

     gcloud container clusters update ${cluster} --update-labels=mesh_id=${Env:MESH_ID}
     gcloud container clusters update ${cluster} --workload-pool=${Env:WORKLOAD_POOL}
     gcloud container clusters update ${cluster} --enable-stackdriver-kubernetes

     kubectl create clusterrolebinding cluster-admin-binding `
       --clusterrole=cluster-admin `
       --user=${GCP_EMAIL_ADDRESS}

     gcloud container hub memberships register $cluster `
       --project=${PROJECT_ID} `
       --gke-cluster=$region_zone/${cluster} `
       --service-account-key-file=${LOCAL_KEY_PATH}
   }
   else
   {
     gcloud container hub memberships register $cluster `
       --project=${PROJECT_ID} `
       --context=${cluster} `
       --kubeconfig=${KUBECONFIG_PATH} `
       --service-account-key-file=${LOCAL_KEY_PATH}
   }  

   kubectl apply -f ${config_directory}/node-reader.yaml 

   #https://cloud.google.com/anthos/multicluster-management/console/logging-in
   #Creating and authorizing a Kubernetes service account (KSA)
   $KSA_NAME = "ksa-${cluster}"
   $VIEW_BINDING_NAME = "view-role-ksa-${cluster}"
   $NODE_READER_BINDING_NAME = "node-reader-role-ksa-${cluster}"
   $BINDING_NAME = "cluster-admin-role-ksa-${cluster}"
   kubectl create serviceaccount ${KSA_NAME}
   kubectl create clusterrolebinding ${VIEW_BINDING_NAME} --clusterrole view --serviceaccount default:${KSA_NAME}
   kubectl create clusterrolebinding ${NODE_READER_BINDING_NAME} --clusterrole node-reader --serviceaccount default:${KSA_NAME}
   kubectl create clusterrolebinding ${BINDING_NAME} --clusterrole cluster-admin --serviceaccount default:${KSA_NAME}

   $VIEW_BINDING_NAME = "view-role-${USER_INITIAL}-${cluster}"
   $NODE_READER_BINDING_NAME = "node-reader-role-${USER_INITIAL}-${cluster}"
   $BINDING_NAME = "cluster-admin-role-ksa-${USER_INITIAL}-${cluster}"
   kubectl create clusterrolebinding ${VIEW_BINDING_NAME} --clusterrole view --user default:${GCP_EMAIL_ADDRESS}
   kubectl create clusterrolebinding ${NODE_READER_BINDING_NAME} --clusterrole node-reader --user default:${GCP_EMAIL_ADDRESS}
   kubectl create clusterrolebinding ${BINDING_NAME} --clusterrole cluster-admin --user default:${GCP_EMAIL_ADDRESS}

   #Get the KSA's beaer token
   $SECRET_NAME=$(kubectl get serviceaccount ${KSA_NAME} -o jsonpath='{$.secrets[0].name}')
   $encoded_token=$(kubectl get secret ${SECRET_NAME} -o jsonpath='{$.data.token}')
   echo "create and save token to ${TOKEN_DIR}/${cluster}"
   [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(${encoded_token})) > ${TOKEN_DIR}/${cluster}
}
