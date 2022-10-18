###############################################################################################
# OPEN TO WORLD SECURITY GROUP SCAN
# Description:
# Verifies any security groups in your AWS account that allow world-access.
#
# Version: 1.0.0
# Author: Rick Trotter
#
###############################################################################################
# ------------------------------------ Set Defaults -------------------------------------------
Param (
    $profileName = "default",
    $outputType = "text",
    $displayType = "short"
)

Clear-Host
Write-Host "*** You will potentially need to be on the VPN to verify this service ***" -BackgroundColor Red
Write-Host "Find Security Groups open to the World ( 0.0.0.0/0 )" -ForegroundColor Green
$myprompt = 'Which AWS profile? ( default is: ' + $profileName + ' )'
# Check which profile to use
$profileChoice = Read-Host -Prompt $myprompt
# Check for what profile - if an entry given update the default
if(-not ([string]::IsNullOrEmpty($profileChoice))){
    $profileName = $profileChoice
}

$myprompt = 'Which Output Type? ( text/json/yaml/table ; default is: ' + $outputType + ' )'
# Check which output type to use
$outputChoice = Read-Host -Prompt $myprompt
# Check for what profile - if an entry given update the default
if(-not ([string]::IsNullOrEmpty($outputChoice))){
    $outputType = $outputChoice
}

$myprompt = 'Full or Short? ( full/short ; default is: ' + $displayType + ' )'
# Check which output type to use
$displayChoice = Read-Host -Prompt $myprompt
# Check for what profile - if an entry given update the default
if(-not ([string]::IsNullOrEmpty($displayChoice))){
    $displayType = $displayChoice
}
Write-Host "############################################################################" -ForegroundColor Yellow
if($displayType -eq "full"){
    aws ec2 describe-security-groups --filters Name=ip-permission.cidr,Values='0.0.0.0/0'  --query "SecurityGroups[*].[*]"  --output $outputType --profile $profileName
}
else{
    aws ec2 describe-security-groups --filters Name=ip-permission.cidr,Values='0.0.0.0/0'  --query "SecurityGroups[*].[GroupName]"  --output $outputType --profile $profileName
}

Write-Host "############################################################################" -ForegroundColor Yellow

