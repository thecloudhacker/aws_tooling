param (
    [string]$deploymentEnvironment,
    [string]$clientName,
    [string]$deployOrPlan
)
$ErrorActionPreference = "Stop"

####### Initialization of Terraform #####

Write-Host "------- Initialising Terraform --------"
terraform init -backend-config="$deploymentEnvironment\backend-config.tfvars"  -backend-config="bucket=$clientName-terraform"

Write-Host "Using S3 backend configuration:"
Write-Host "$deploymentEnvironment\backend-config.tfvars \nbucket=$clientName-terraform\n\n"

if ($LASTEXITCODE -ne 0){
    exit 1
}

###########################################################################
#                                                                         #
# CI/CD TOOLING - SETUP SCRIPT FOR USE IN TOOLING SYSTEM SUCH AS TEAMCITY #
#                                                                         #
###########################################################################

####### Plan or Build Terraform #########

Write-Host "------- Executing Terraform --------"
$myCurrentPath = ($pwd).path
Write-Host "Current Directory: $myCurrentPath"
Write-Host "Environment: $deploymentEnvironment"

# Check if we are about to do a plan or a deploy ( default is plan )
if ($deployOrPlan -eq "deploy") {
    Write-Host "===: EXECUTING APPLY :===`n"

    terraform apply -var-file="$deploymentEnvironment\variables.tfvars" -var "account_name=$clientName" -var "location_env=$deploymentEnvironment" -auto-approve 

}
else {
    Write-Host "===: EXECUTING PLAN :===`n"

    terraform plan -var-file="$deploymentEnvironment\variables.tfvars" -var "account_name=$clientName" -var "location_env=$deploymentEnvironment" 

}

if ($LASTEXITCODE -ne 0) {
    exit 1
}