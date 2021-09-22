param(
    [string]$env,
    [string]$systype
)

# Script to Access AWS Keys for running infrastructure for the correct environment

$ErrorActionPreference = "Stop"

Set-DefaultAWSRegion -Region "eu-west-2"

Write-Host "Using : /gingerco/deploy/$env/$systype/deployment_access/access.key"


$key = Get-SSMParameter -Name "/gingerco/deploy/$env/$systype/deployment_access/access.key"
$secret = Get-SSMParameter -Name "/gingerco/deploy/$env/$systype/deployment_access/secret.key" -WithDecryption $true

$keyValue = $key.Value
$secretValue = $secret.Value

Write-Host "------------------ DROPPING OLD KEYS ---------------"
Write-Host "Deployment Key: $Env:AWS_ACCESS_KEY"
Write-Host "----------------------------------------------------"

# Set the initial keys to CLOUD to drop-out of that context
Write-Host "##teamcity[setParameter name='env.CLOUD_ACCESS_KEY' value='$Env:AWS_ACCESS_KEY']"
Write-Host "##teamcity[setParameter name='env.CLOUD_SECRET_KEY' value='$Env:AWS_SECRET_KEY']"

# Set the new deployment keys as the defaults
Write-Host "##teamcity[setParameter name='env.AWS_ACCESS_KEY' value='$keyValue']"
Write-Host "##teamcity[setParameter name='env.AWS_SECRET_KEY' value='$secretValue']"
Write-Host "----------------- NEW KEYS SET ---------------------"
Write-Host "Deployment Key: $keyValue"
Write-Host "----------------------------------------------------"
