# https://cloud.google.com/anthos/multicluster-management/connect/registering-a-cluster?hl=en_US#before_you_begin

$bin_directory  = Split-Path $myInvocation.MyCommand.path
$root_directory = Split-Path -Path ${bin_directory} -Parent
$repo_parent_directory = Split-Path -Path ${root_directory} -Parent
$config_directory = "${root_directory}/config"

.  ${bin_directory}/env.ps1



for ( $i=0; $i -lt $clusters.length;  $i++)
{
   $cluster = $clusters[$i]
   $region_zone = $region_zones[$i]
   echo "Uninstall HPCC cluster on $cluster on region $region_zone"
   kubectl config use-context $cluster
   kubectl config set-context $cluster --namespace=${hpcc_namespace}

   helm uninstall ${hpcc_cluster_name}
   sleep 5
   if ( $storage_types[$i] -eq "efs" )
   {
   
     helm uninstall efsstorage
   }
   elseif ( $storage_types[$i] -eq "azure" )
   {
     helm uninstall azstorage
   }
   elseif ( $storage_types[$i] -eq "nfs" )
   {
     helm uninstall nfsstorage
   }
   else
   {
      "local storage"
   }
   kubectl delete pv --all


}

