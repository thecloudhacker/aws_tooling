#########################################################################
# COGNITO USER SCRIPT
# POWERSHELL TO PULL USERS AND CHECK IF THEY HAVE ACCESSED THE PLATFORM
# Author: R. Trotter
#########################################################################
Param(
    $awsprofile = "default"
)

Write-Output "------ COGNITO USERS: BEGIN PROCESS -------"

#
# Clean-up Routine
# Gets rid of the previous version file so you don't end up with duplicates
#
Write-Output "[Running Local File Cleanup]"
Remove-Item -Path cognitouserlist.txt

#
# CREATE USER FILE
# Create the current users file by running a cognito call


# Ask for the AWS profile
$myprompt = 'Which AWS profile? ( default is: ' + $awsprofile + ' )'
# Check which profile to use
$profileChoice = Read-Host -Prompt $myprompt
# Check for what profile - if an entry given update the default
if(-not ([string]::IsNullOrEmpty($profileChoice))){
    $awsprofile = $profileChoice
}

# Ask for the Cognito Pool ID to use
$myprompt = 'What is the Cognito Pool ID?'
# Check which profile to use
$cogpoolid = Read-Host -Prompt $myprompt


Write-Output "[Creating User List...]"
aws cognito-idp list-users --user-pool-id $cogpoolid --attributes-to-get email --profile $awsprofile > cognitouserlist.txt
# The user list is now stored in the script's folder as cognitouserlist.txt

#
# READ USER FILE 
# Read user File and find the email addresses & Authentications

$jsonFile = Get-Content -Raw -Path cognitouserlist.txt | ConvertFrom-Json
# Read and convert from JSON format ready for processing

# SET UP LOCAL VARIABLES
$theDate = Get-Date -Format "yyyyMMdd"
$outputFile = "$theDate-userStatusOutput.csv" # THE OUTPUT USER CSV FILE

# WRITE THE HEADER LINE TO THE CSV
$NewLine = "{0},{1},{2},{3}" -f "STATUS","USERNAME","COGNITO STATUS","LAST EVENT"
$NewLine | add-content -path $outputFile

$i = 0 # Main user counter

Write-Output "[Beginning JSON read...]"

# Loop through all users in the file
$jsonFile | foreach {
    $users = $_.Users
    $users | foreach {
        %{
            # Loop Through the users and get the email address from the Attributes sub array
            $data = $_.Attributes;
            $userStatus = $_.UserStatus;
            $arrayUser = $data -split '\s+';
            ## Clean Up the Output string 
            $cleanInfo = $arrayUser[1] -replace "Value=",""
            $cleanInfo2 = $cleanInfo -replace "}",""

            ## Make a call to verify if user has had any activity
            $readEvents = aws cognito-idp admin-list-user-auth-events --user-pool-id $cogpoolid --max-items 1 --username $cleanInfo2 --profile $awsprofile | ConvertFrom-Json
            $authCount = 0; # RESET COUNTER
            $eventID = ""; # RESET EVENT SEARCH
            # Loop through auth events to count them
            $readEvents | foreach {
                %{
                    $authEvents = $_.AuthEvents
                    ## Increment if there is an event ID ( someone has logged in )
                    $eventID = $authEvents.EventId
                    $eventDate = $authEvents.CreationDate
                    if($eventID){
                        $authCount++
                    }
                }
            }
            if($authCount -gt 0 ){
                # User has signed-in to the platform in it's account life
                Write-Output "ACTIVE, $cleanInfo2, $userStatus, $eventDate";
                $NewLine = "{0},{1},{2},{3}" -f "ACTIVE",$cleanInfo2,$userStatus,$eventDate
            }
            else{
                # User has NOT signed-in to the platform in it's account life
                Write-Output "DORMANT, $cleanInfo2, $userStatus";
                $NewLine = "{0},{1},{2},{3}" -f "DORMANT",$cleanInfo2,$userStatus,$eventDate
            }
            # Add the line to the new CSV file
            $NewLine | add-content -path $outputFile
            $i++
        }
    }
}

Write-Output "------------- PROCESS COMPLETE ------------"
Write-Output "User total: $i"
Write-Output "-------------------------------------------"