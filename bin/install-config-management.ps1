# https://cloud.google.com/anthos-config-management/docs/how-to/installing?hl=en_US

$bin_directory  = Split-Path $myInvocation.MyCommand.path
$root_directory = Split-Path -Path ${bin_directory} -Parent
$repo_parent_directory = Split-Path -Path ${root_directory} -Parent
$config_directory = "${root_directory}/config"

.  ${bin_directory}/env.ps1


$cfg_mgt_operator_yaml = "${DOWNLOAD_DIR}/config-management-operator.yaml"
if (!(Test-Path ${cfg_mgt_operator_yaml} -PathType Leaf))
{
  gsutil cp gs://config-management-release/released/latest/config-management-operator.yaml ${cfg_mgt_operator_yaml}
}

for ( $i=0; $i -lt $clusters.length;  $i++)
{
  $cluster = $clusters[$i]
  "Ininstall Anthos-config-management on $cluster"
  kubectl config use-context $cluster
  #kubectl apply -f ${cfg_mgt_operator_yaml}
  kubectl apply -f ${config_directory}/config-management.yaml --context $cluster
  #if ($cluster_is_gke[$i])
  #{
  #}
} 

