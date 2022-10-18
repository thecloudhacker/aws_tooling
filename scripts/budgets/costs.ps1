#####################################################################################################
#
#  AWS Cost Query System
#  ---------------------
#  Description:
#  Derives monthly costs from AWS API Mechanisms.
# 
#  Accepts parameters or will prompt:
#   -profileName                      ( your AWS profile name )
#   -startDate                        ( not setting will default to the start of the current month)
#   -endDate                          ( not setting will default to the current date )
#   -prompt y/n                       ( this will prompt you for the date ranges )
#   -outputType table/json/yaml/text  ( this will default to table if left out )
#
#  Version: 1.0.1
#  Author:  Rick Trotter
#
#####################################################################################################


# Load Default Settings from command prompt if available
param (
    [string]$profileName,
    [string]$startDate,
    [string]$endDate,
    [string]$outputType = "table",
    [string]$prompt = "n"
)

## set globals
$global:startDate=$startDate
$global:endDate=$endDate

## Clear terminal and write banner
Clear-Host
Write-Host "#################################################################################" -ForegroundColor Green
Write-Host " █████╗ ██╗    ██╗███████╗    ██████╗ ██╗   ██╗██████╗  ██████╗ ███████╗████████╗" -ForegroundColor Green
Write-Host "██╔══██╗██║    ██║██╔════╝    ██╔══██╗██║   ██║██╔══██╗██╔════╝ ██╔════╝╚══██╔══╝" -ForegroundColor Green
Write-Host "███████║██║ █╗ ██║███████╗    ██████╔╝██║   ██║██║  ██║██║  ███╗█████╗     ██║   " -ForegroundColor Green
Write-Host "██╔══██║██║███╗██║╚════██║    ██╔══██╗██║   ██║██║  ██║██║   ██║██╔══╝     ██║   " -ForegroundColor Green
Write-Host "██║  ██║╚███╔███╔╝███████║    ██████╔╝╚██████╔╝██████╔╝╚██████╔╝███████╗   ██║   " -ForegroundColor Green
Write-Host "╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝    ╚═════╝  ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝   ╚═╝  " -ForegroundColor Green
Write-Host "             WORKING OUT HOW MUCH AWS HAS COST YOU IN YOUR ACCOUNT" -ForegroundColor Red
Write-Host "#################################################################################" -ForegroundColor Green

############ Verify if there is a profile name specified  ###############
if([string]::IsNullOrEmpty($profileName)){
    # Verify The AWS Profile to use as none has been supplied
    $profileName = "default"
    $myprompt = 'Which AWS profile? ( default is: ' + $profileName + ' )'
    # Check which profile to use
    $profileChoice = Read-Host -Prompt $myprompt
    # Check for what profile - if an entry given update the default
    if(-not ([string]::IsNullOrEmpty($profileChoice))){
        $profileName = $profileChoice
    }
}


##### Get the current costs for the month ##########
function getCostsForMonth{
    # Get the current cost information from  AWS
    aws ce get-cost-and-usage --time-period Start=$global:startDate,End=$global:endDate --granularity MONTHLY --metrics "BlendedCost" --output $outputType --profile $profileName
}

###### VERIFY SSO IS LOGGED IN ELSE PROMPT FOR IT  ######
function verifyAuth{
    # Run an SSO call to work out if you are currently signed-in and if not, authenticate yourself
    $areYouAuthenticated = aws sts get-caller-identity --query "Account" --profile $profileName
    # If the returned string call is greater than zero or null it is an account ID returned
    if( $areYouAuthenticated.Length -gt 1 ){
        # Session valid
        getCostsForMonth
    }
    else{
        # Run Session Auth
        Write-Host "AWS Session timed-out, re-authenticate please..."
        aws sso login --profile $profileName
        # Once signed-in then run the cost analysis
        getCostsForMonth
    }
}

##### Get date ranges   ########
# If there are items set then they will be used else the system will prompt or use automatic dates
function getDateRanges{
    # If the date ranges have been passed into the script, use those, otherwise request dates

    if([string]::IsNullOrEmpty($global:startDate)){
        # Verify The AWS Profile to use as none has been supplied
        $startProcessedDate = Get-Date -Format "yyyy-MM"
        $global:startDate = $startProcessedDate + "-01"
        if($prompt -eq "y"){
            $myprompt = 'What start date? ( YYYY-MM-DD format, default is: ' + $startDate + ' )'
            # Check which profile to use
            $startDateChoice = Read-Host -Prompt $myprompt
            # Check for what profile - if an entry given update the default
            if(-not ([string]::IsNullOrEmpty($startDateChoice))){
                $global:startDate = $startDateChoice
            }
        }
    }

    if([string]::IsNullOrEmpty($global:endDate)){
        # Verify The AWS Profile to use as none has been supplied
        $global:endDate = Get-Date -Format "yyyy-MM-dd"

        if($prompt -eq "y"){
            $myprompt = 'What end date? ( YYYY-MM-DD format, default is: ' + $endDate + ' )'
            # Check which profile to use
            $endDateChoice = Read-Host -Prompt $myprompt
            # Check for what profile - if an entry given update the default
            if(-not ([string]::IsNullOrEmpty($endDateChoice))){
                $global:endDate = $endDateChoice
            }
        }
    }
}

######################################################################
######## Clear the screen and run the application hooks ##############
### Script Launch:
getDateRanges
verifyAuth


