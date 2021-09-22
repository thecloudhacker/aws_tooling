param (
    [string]$deploymentEnvironment,
    [string]$clientName,
    [string]$deployOrPlan
)
$ErrorActionPreference = "Stop"


###########################################################################
#                                                                         #
# CI/CD TOOLING - SETUP SCRIPT FOR USE IN TOOLING SYSTEM SUCH AS TEAMCITY #
#                                                                         #
###########################################################################

# Create S3 log bucket 

# Initialise terraform
terraform init

Write-Host "-------[ Executing Terraform ]-------`n"
# Check if we are about to do a plan or a deploy ( default is plan )
if ($deployOrPlan -eq "deploy") {
    Write-Host "===xX: EXECUTING APPLY :Xx===`n"
    terraform apply -var-file="$deploymentEnvironment\variables.tfvars"  -var "account_name=$clientName" -var "location_env=$deploymentEnvironment" -auto-approve 
}
else {
    Write-Host "===oO: EXECUTING PLAN :Oo===`n"
    terraform plan -var-file="$deploymentEnvironment\variables.tfvars"  -var "account_name=$clientName" -var "location_env=$deploymentEnvironment"
}

Write-Host "-------[ PROCESS COMPLETE ]-------`n"

if ($LASTEXITCODE -ne 0) {
    exit 1
}