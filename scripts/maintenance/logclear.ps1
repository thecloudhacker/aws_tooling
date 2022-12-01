##################################################################################
#
#  LogClear  - Clear Out AWS CloudWatch Log Groups
#  -------------------------------------------
#  Description:
#  Deletes log groups - either all but an exclusion list, or those matching a pattern
#  provided by the user.
#
#  ===================================================
#
#               !!!! WARNING !!!!
#   This process is destructive and will delete log
#   groups from the system. If you have it set to 
#   automatic mode ( default ) it will not prompt you
#   to confirm after the initial confirmation you 
#   understand the risk. If you set it to SILENT 
#   you will not be prompted to continue the task.
#
#  ===================================================
#
#  Accepts parameters or will prompt:
#   -profileName   ( your AWS profile name )
#   -pattern       ( a pattern to match to delete )
#   -prompt y/n    ( this will prompt you for each log group item )
#   -silent y/n    ( default is n - to ensure you are asked to continue )
#
#  Version: 1.0.0
#  Author:  R.  Trotter
#
##################################################################################

# Load Default Settings from command prompt if available
param (
    [string]$profileName,
    [string]$pattern = "",
    [string]$output = "",
    [string]$prompt = "n",
    [string]$silent = "n"
)

# List of groups to exclude - these can be for things that you do not EVER want to delete in the process
$global:excludeGroup= @('aws-controltower/CloudTrailLogs')
# Global counter for number of log groups searched through
$global:logsCount=0
$global:foundCount=0
$global:outputFile=""

# Create a list of all the log groups on the system
function enumerateGroups{
    $allLogGroups = aws logs describe-log-groups --profile $profileName --output json | ConvertFrom-Json
    $allLogGroups | foreach {
        %{
            $logEntry=$_.logGroups
            $logGroupNames=$logEntry.logGroupName
            $logGroupNameArray=$logGroupNames.Split(" ")
            $logGroupNameArray | foreach {
                $nameString=$logGroupNameArray[$global:logsCount]
                if($global:excludeGroup.Contains($nameString)){
                    Write-Host "Log Group in Exclude list: $nameString  ****" -ForegroundColor Red
                }
                else{
                    if(-not ([string]::IsNullOrEmpty($pattern))){
                        if($namestring.Contains($pattern)){
                            Write-Host "Found Pattern $pattern in $nameString" -ForegroundColor White
                            $global:foundCount++
                            deleteLogGroup $namestring
                        }
                    }
                    else{
                        Write-Host "Found Group: $nameString" -ForegroundColor Green
                        $global:foundCount++
                        deleteLogGroup $nameString
                    }
                }
                $global:logsCount++
            }
        }
    }
    if(-not ([string]::IsNullOrEmpty($pattern))){
        $outputMessage = "Search Completed, found $global:foundCount matches in $global:logsCount log groups"
    }
    else{
        $outputMessage = "Search Completed, $global:logsCount log groups discovered"
    }
    Write-Host "$outputMessage" -ForegroundColor Yellow
}

# Delete a log group from the AWS CloudWatch records
function deleteLogGroup($logName){
    if($prompt -eq "y"){
        $myprompt = 'Do you want to delete "' + $logName + '" (y/N)'
        $deleteMe = Read-Host -Prompt $myprompt
        # Check if you want to delete or not
        if($deleteMe -eq "y"){
            aws logs delete-log-group --log-group-name $logName --profile $profileName
            $NewLine = "{0},{1},{2}" -f "DELETED",$logName,"PROMPT Y"
            Write-Host "Deleted $logName" -ForegroundColor Black -BackgroundColor Red
        }
        else{
            $NewLine = "{0},{1},{2}" -f "RETAINED",$logName,"PROMPT N"
            Write-Host "Keeping $logName" -ForegroundColor Black -BackgroundColor Green
        }
    }
    else{
        aws logs delete-log-group --log-group-name $logName --profile $profileName
        $NewLine = "{0},{1},{2}" -f "DELETED",$logName,"AUTOMATIC"
        Write-Host "Automatic mode: Deleted $logName" -ForegroundColor Black -BackgroundColor Red
    }
    if($output -eq 'y'){
        $NewLine | add-content -path $global:outputFile
    }
}

# File output generation routines - opening and header of the file
function CreateFileOutput {
    $theDate = Get-Date -Format "yyyyMMdd"
    $global:outputFile = "$theDate-log-group-deletion.csv" # THE OUTPUT USER CSV FILE
    # WRITE THE HEADER LINE TO THE CSV
    $NewLine = "{0},{1},{2}" -f "STATUS","LOG GROUP","MODE"
    $NewLine | add-content -path $global:outputFile
    Write-Host "Creating Output File : $global:outputFile" -BackgroundColor Yellow -ForegroundColor Black
}

########################## MAIN SCRIPT RUN PHASE - FIRST LAUNCH RUNS HERE =============================>
Clear-Host
Write-Host "888   Cloud Hacker's   .d8888b.  888                           " -ForegroundColor Blue
Write-Host "888                   d88P  Y88b 888                           " -ForegroundColor Blue
Write-Host "888                   888    888 888                           " -ForegroundColor Blue
Write-Host "888  .d88b.   .d88b.  888        888  .d88b.   8888b.  888d888 " -ForegroundColor Blue
Write-Host "888 d88  88b d88P 88b 888        888 d8P  Y8b      88b 888P    " -ForegroundColor Blue
Write-Host "888 888  888 888  888 888    888 888 88888888 .d888888 888     " -ForegroundColor Blue
Write-Host "888 Y88..88P Y88b 888 Y88b  d88P 888 Y8b.     888  888 888     " -ForegroundColor Blue
Write-Host "888   Y88P     Y88888   Y8888P   888  Y8888    Y888888 888     " -ForegroundColor Blue
Write-Host "                  888                                          " -ForegroundColor Blue
Write-Host "            Y8b d88P                                           " -ForegroundColor Blue
Write-Host "              Y88P                    v 1.0.0                  " -ForegroundColor Blue

if($silent -eq 'y'){
    Write-Host "SILENT MODE: NO PROMPTING" -ForegroundColor Black -BackgroundColor Red
    if($output -eq 'y'){
        CreateFileOutput
    }
    enumerateGroups
}
else{
    $myprompt = "This is a destructive task - Do you want to continue this process"
    $goProcess = Read-Host -Prompt $myprompt
    # Check if you want to delete or not
    if($goProcess -eq "y"){
        Write-Host "Continuing...." -ForegroundColor Black -BackgroundColor Green
        if($output -eq 'y'){
            CreateFileOutput
        }
        enumerateGroups
    }
    else{
        Write-Host "EXIT! ARGH! CANCEL!" -ForegroundColor Red
        
    }
}