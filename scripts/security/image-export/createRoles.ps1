#####################################################
#                                                   #
# Generate IAM Roles and Policies For Image Export  #
#                                                   #
# Required to be run per account                    #
#                                                   #
#####################################################


# Get the current path to work out where the json files are
$mypath = Get-Location

Write-Host "Current Path is: {$mypath} is this correct?"

# Verify The AWS Profile to use - Default profile is 'default'
$profileName = "default"
$myprompt = 'Which AWS profile? ( default is: ' + $profileName + ' )'
$profileChoice = Read-Host -Prompt $myprompt
# Check for what profile - if an entry has been given, update the default
if(-not ([string]::IsNullOrEmpty($profileChoice))){
    $profileName = $profileChoice
}


# Generate the specific role the export routine requires
Write-Host "Creating Role 'vmimport' in your AWS Account..." -ForegroundColor Green
aws iam create-role --role-name vmimport --assume-role-policy-document "file://$mypath/trust-policy.json" --profile $profileName
# Generate the policy and attach to the role just generated
Write-Host "Creating the Policy 'vmimport' attached to your 'vmimport' role..." -ForegroundColor Green
aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file://$mypath/role-policy.json" --profile $profileName

# exit process
Write-Host "Process Complete" -BackgroundColor Green -ForegroundColor Black