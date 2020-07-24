# https://cloud.google.com/anthos/multicluster-management/connect/registering-a-cluster?hl=en_US#before_you_begin

$bin_directory  = Split-Path $myInvocation.MyCommand.path
$root_directory = Split-Path -Path ${bin_directory} -Parent
$repo_parent_directory = Split-Path -Path ${root_directory} -Parent
$config_directory = "${root_directory}/config"

.  ${bin_directory}/env.ps1

#gcloud iam service-accounts list

if (!(Test-Path -path $TOKEN_DIR))
{
   New-Item -ItemType directory -Path ${TOKEN_DIR}
}

foreach ($cluster in $clusters)
{
   echo "Register cluster: $cluster"
   gcloud container hub memberships register $cluster `
     --project=${PROJECT_ID} `
     --context=${cluster} `
     --kubeconfig=${KUBECONFIG_PATH} `
     --service-account-key-file=${LOCAL_KEY_PATH}

   kubectl apply -f ${config_directory}/node-reader.yaml 

   #Creating and authorizing a KSA
   $KSA_NAME = "ksa-${cluster}"
   $VIEW_BINDING_NAME = "view-role-ksa-${cluster}"
   $NODE_READER_BINDING_NAME = "node-reader-role-ksa-${cluster}"
   $BINDING_NAME = "cluster-admin-role-ksa-${cluster}"
   kubectl create serviceaccount ${KSA_NAME}
   kubectl create clusterrolebinding ${VIEW_BINDING_NAME} --clusterrole view --serviceaccount default:${KSA_NAME}
   kubectl create clusterrolebinding ${NODE_READER_BINDING_NAME} --clusterrole node-reader --serviceaccount default:${KSA_NAME}
   kubectl create clusterrolebinding ${BINDING_NAME} --clusterrole cluster-admin --serviceaccount default:${KSA_NAME}

   $VIEW_BINDING_NAME = "view-role-${USER_INITIAL}"
   $NODE_READER_BINDING_NAME = "node-reader-role-${USER_INITIAL}"
   $BINDING_NAME = "cluster-admin-role-ksa-${USER_INITIAL}"
   kubectl create clusterrolebinding ${VIEW_BINDING_NAME} --clusterrole view --user default:${GCP_EMAIL_ADDRESS}
   kubectl create clusterrolebinding ${NODE_READER_BINDING_NAME} --clusterrole node-reader --user default:${GCP_EMAIL_ADDRESS}
   kubectl create clusterrolebinding ${BINDING_NAME} --clusterrole cluster-admin --user default:${GCP_EMAIL_ADDRESS}

   #Get the KSA's beaer token
   $SECRET_NAME=$(kubectl get serviceaccount ${KSA_NAME} -o jsonpath='{$.secrets[0].name}')
   $encoded_token=$(kubectl get secret ${SECRET_NAME} -o jsonpath='{$.data.token}')
   [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(${encoded_token})) > ${TOKEN_DIR}/${cluster}
}
