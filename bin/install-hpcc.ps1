# https://cloud.google.com/anthos/multicluster-management/connect/registering-a-cluster?hl=en_US#before_you_begin

$bin_directory  = Split-Path $myInvocation.MyCommand.path
$root_directory = Split-Path -Path ${bin_directory} -Parent
$repo_parent_directory = Split-Path -Path ${root_directory} -Parent
$config_directory = "${root_directory}/config"

.  ${bin_directory}/env.ps1

$HPCC_PLATFORM_DIR = "${BUILD_DIR}/HPCC-Platform"
if (!(Test-Path -path $HPCC_PLATFORM_DIR))
{
   git clone https://github.com/${git_user}/HPCC-Platform.git ${HPCC_PLATFORM_DIR}
}

cd ${HPCC_PLATFORM_DIR}
$hpcc_branch = $(git branch | grep "^*" | grep ${hpcc_version})
if (${hpcc_branch} -eq $null)
{
   $tag = $(git tag | grep ${hpcc_versioin})
   if ( $tag -eq $null )
   {
     git checkout ${hpcc_version}
   }
   else
   {
     git checkout tags/${hpcc_version}
   }
}


for ( $i=0; $i -lt $clusters.length;  $i++)
{
   $cluster = $clusters[$i]
   $region_zone = $region_zones[$i]
   echo "Install HPCC cluster on $cluster on region $region_zone"
   kubectl config use-context $cluster
   $found = $(kubectl get ns | grep "^${hpcc_namespace}")
   if (${found} -eq $null)
   {
      "Create namespace ${hpcc_namespace}"
      kubectl create namespace ${hpcc_namespace}
   }

   kubectl config set-context $cluster --namespace=${hpcc_namespace}
   kubectl label namespace ${hpcc_namespace} istio-injection=enabled

   cd "helm"
   if ( $storage_types[$i] -eq "efs" )
   {
   
     helm install efsstorage examples/efs/hpcc-efs --set efs.region=$region_zone `
        --set efs.id=${efs_id} --set efs.namespace=${hpcc_namespace}
     sleep 5
     helm install ${hpcc_cluster_name} hpcc/ --set global.image.version=${hpcc_version} `
         -f examples/efs/values-efs.yaml
   }
   elseif ( $storage_types[$i] -eq "azure" )
   {
     helm install azstorage examples/azure/hpcc-azurefile
     sleep 5
     helm install ${hpcc_cluster_name} hpcc/ --set global.image.version=${hpcc_version} `
         -f examples/azure/values-auto-azurefile.yaml
   }
   elseif ( $storage_types[$i] -eq "nfs" )
   {
     helm install nfsstorage examples/nfs/hpcc-nfs/
     sleep 5
     helm install ${hpcc_cluster_name} hpcc/ --set global.image.version=${hpcc_version} `
         -f examples/nfs/values-nfs.yaml
   }
   else
   {
      "local storage"
   }


}

cd $bin_directory
