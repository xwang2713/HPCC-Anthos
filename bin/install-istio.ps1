# https://cloud.google.com/service-mesh/docs/attached-clusters-install
$bin_directory  = Split-Path $myInvocation.MyCommand.path
$root_directory = Split-Path -Path ${bin_directory} -Parent
$repo_parent_directory = Split-Path -Path ${root_directory} -Parent
$config_directory = "${root_directory}/config"

.  ${bin_directory}/env.ps1



$istio_package_base = "istio-1.6.5-asm.7" 
$istio_package = "${istio_package_base}-win.zip" 
$istio_package_path = "${DOWNLOAD_DIR}/${istio_package}" 


if (!(Test-Path ${istio_package_path} -PathType Leaf))
{

  Invoke-WebRequest -Uri https://storage.googleapis.com/gke-release/asm/${istio_package} -OutFile ${DOWNLOAD_DIR}/${istio_package}
  Invoke-WebRequest -Uri https://storage.googleapis.com/gke-release/asm/${istio_package_base}-win.zip.1.sig -OutFile ${DOWNLOAD_DIR}/${istio_package_base}-win.zip.1.sig
  Try 
  {
    if (Get-Command openssl -errorAction SilentlyContinue)
    {
      echo "openssl verify download istio package signature ..."
     # Beware following key is only for this ISTIO package.
@'
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEWZrGCUaJJr1H8a36sG4UUoXvlXvZ
wQfk16sxprI2gOJ2vFFggdq3ixF2h4qNBt0kI7ciDhgpwS8t+/960IsIgw==
-----END PUBLIC KEY-----
'@ | openssl dgst -verify - -signature ${DOWNLOAD_DIR}/istio-1.6.5-asm.7-win.zip.1.sig ${istio_package_path} 
    }
  }
  Catch
  {
     "Cannot find openssl command. Skip verifying istio package signature"
  }
  Expand-Archive -LiteralPath ${istio_package_path}  -DestinationPath  ${DOWNLOAD_DIR}
}

if ( $Env:Path.Indexof("${DOWNLOAD_DIR}/${istio_package_base}/bin") -eq -1) 
{
  "Add ISTIO directory bin to PATH"
  $Env:Path = "${DOWNLOAD_DIR}/${istio_package_base}/bin;" + $Env:Path
}

for ( $i=0; $i -lt $clusters.length;  $i++)
{
  $cluster = $clusters[$i]
  $region_zone = $region_zones[$i]
  "Ininstall Istio on $cluster"
  kubectl config use-context $cluster
  kubectl create clusterrolebinding cluster-admin-binding `
    --clusterrole=cluster-admin `
    --user=${GCP_EMAIL_ADDRESS}

  if ($cluster_types[$i] -eq "gcp")
  {
     if ( -Not (Get-Command kpt -errorAction SilentlyContinue) )
     {
        gcloud components install kpt
     }
     kpt pkg get  https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages.git/asm@release-1.6-asm .
     kpt cfg set asm gcloud.container.cluster ${cluster}
     kpt cfg set asm gcloud.core.project ${PROJECT_ID}
     kpt cfg set asm gcloud.compute.location ${region_zone}
     istioctl install -f asm/cluster/istio-operator.yaml

     Remove-Item 'asm' -Recurse
  }
  else
  {
     $asm_profile =  "asm-multicloud"
     "Profile:  ${asm_profile}"
     istioctl.exe install --set profile=${asm_profile}
  }
} 

