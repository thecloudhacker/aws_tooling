param (
    [string]$deploymentEnvironment,
    [string]$destroyOrExit
)
$ErrorActionPreference = "Stop"

#############################################################################
#                                                                           #
# CI/CD TOOLING - DESTROY SCRIPT FOR USE IN TOOLING SYSTEM SUCH AS TEAMCITY #
#                                                                           #
#############################################################################

####### Destroy Terraform #########

Write-Host "-------xX Executing Terraform Destroy Xx--------"
$myCurrentPath = ($pwd).path
Write-Host "Current Directory: $myCurrentPath"
Write-Host "Environment: $deploymentEnvironment"

# Check if we really want to destroy the infrastructure ( default is no )
if ($destroyOrExit -eq "confirm") {
    Write-Host "===xX: DESTROYING :Xx===`n"

    terraform destroy -var-file="terraform\$deploymentEnvironment\variables.tfvars" -auto-approve 

}
else {
    Write-Host "===: EXITING - No Change - CANCELLING PROCESS :===`n"

}

if ($LASTEXITCODE -ne 0) {
    exit 1
}