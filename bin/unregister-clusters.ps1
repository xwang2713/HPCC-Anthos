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
   if ($cluster_is_gke[$i])
   {
     $zone = $zones[$i]
     gcloud container hub memberships unregister $cluster `
       --project=${PROJECT_ID} `
       --gke-cluster=$zone/${cluster}
   }
   else
   {
     gcloud container hub memberships unregister $cluster `
       --project=${PROJECT_ID} `
       --context=${cluster} `
       --kubeconfig=${KUBECONFIG_PATH} 
   }  

}
