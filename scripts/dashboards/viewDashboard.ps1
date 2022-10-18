################################
#                              #
# AWS View Dashboard Script    #
# v 1.0.0                      #
# Author: R. Trotter           #
#                              #
################################


# Verify The AWS Profile to use
$myprompt = 'Which AWS profile? ( default is: ' + $profileName + ' )'
    # Check which profile to use
    $profileChoice = Read-Host -Prompt $myprompt
    # Check for what profile - if an entry given update the default
    if(-not ([string]::IsNullOrEmpty($profileChoice))){
        $profileName = $profileChoice
    }


# Display current dashboards?

aws cloudwatch list-dashboards --profile $profileName

Write-Host '  Process Complete ' -ForegroundColor Black -BackgroundColor Green




