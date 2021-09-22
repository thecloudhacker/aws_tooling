param (
    [string]$deploymentEnvironment,
    [string]$clientName,
    [string]$destroyOrExit
)
$ErrorActionPreference = "Stop"


#############################################################################
#                                                                           #
# CI/CD TOOLING - DESTROY SCRIPT FOR USE IN TOOLING SYSTEM SUCH AS TEAMCITY #
#                                                                           #
#############################################################################


####### Initialization of Terraform #####

Write-Host "------- Initialising Terraform --------"
terraform init -backend-config="$deploymentEnvironment\backend-config.tfvars"  -backend-config="bucket=$clientName-terraform"

Write-Host "Using S3 backend configuration:"
Write-Host "$deploymentEnvironment\backend-config.tfvars \nbucket=$clientName-terraform\n\n"

if ($LASTEXITCODE -ne 0){
    exit 1
}

####### Destroy Terraform #########

Write-Host "-------xX Executing Terraform Destroy Xx--------"
$myCurrentPath = ($pwd).path
Write-Host "Current Directory: $myCurrentPath"
Write-Host "Environment: $deploymentEnvironment"

# Check if we really want to destroy the infrastructure ( default is no )
if ($destroyOrExit -eq "confirm") {
    Write-Host "===xX: DESTROYING :Xx===`n"

    terraform destroy -var-file="$deploymentEnvironment\variables.tfvars" -auto-approve 

}
else {
    Write-Host "===: EXITING - No Change - CANCELLING PROCESS :===`n"

}

if ($LASTEXITCODE -ne 0) {
    exit 1
}