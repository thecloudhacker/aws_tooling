##################################################################################
#
#  S3 Maintenance Script - Delete bucket items older than a specified date
#  -----------------------------------------------------------------------
#  Description:
#  Deletes items from an S3 bucket that are older than a given date.
#  If you do not specify to prompt  
#
#  ===================================================
#
#               !!!! WARNING !!!!
#   This process is destructive and will delete s3
#   items from the system. If you have it set to 
#   automatic mode ( default ) it will not prompt you
#   to confirm
#
#  ===================================================
#
#  Accepts parameters or will prompt:
#   -profileName   ( your AWS profile name )
#   -bucketName    ( your AWS S3 Bucket name to delete from )
#   -dateBefore    ( the date you want to delete items before FORMAT: YYYY-MM-DD)
#   -prompt y/n    ( this will prompt you for each log group item )
#
#  Version: 1.0.0
#  Author:  R.  Trotter
#
##################################################################################

# Load Default Settings from command prompt if available
param (
    [string]$profileName,
    [string]$bucketName ="",
    [string]$dateBefore ="",
    [string]$prompt = "n"
)
# Global counter for number of log groups searched through
$global:itemsCount=0
$global:outputFile=""
$global:itemsRemoved=0

# Create a list of all the items to remove in your chosen S3 bucket
function enumerateItems{
    $alls3items = aws s3api list-objects-v2 --profile $profileName --bucket $bucketName --output json | ConvertFrom-Json
    $alls3items | foreach {
        %{
            $s3file=$_.Contents
            $s3file | foreach {
                # Get the json array items from the AWS call one by one
                $itemName=$s3file[$global:itemsCount].Key
                $itemSize=$s3file[$global:itemsCount].Size
                $itemEtag=$s3file[$global:itemsCount].ETag
                $itemDate=$s3file[$global:itemsCount].LastModified
                if(-not ([string]::IsNullOrEmpty($dateBefore))){
                    # If date before supplied check if it matches an entry else skip delete
                    $leftDateField=$itemDate.SubString(0,10)
                    if($leftDateField -le $dateBefore){
                        Write-Host "Found Item: '$itemName' before the date $dateBefore ( $itemDate )" -ForegroundColor Green
                        $global:foundCount++
                        deleteBucketItem $itemName $itemSize $itemEtag $bucketName $itemDate
                        $global:itemsCount++
                    }
                    else{
                        Write-Host "Ignoring Found Item: '$itemName' AFTER the date $dateBefore ( $itemDate )" -ForegroundColor Yellow
                    }
                }
                else{
                    # No date supplied therefore we're deleting everything we can
                    Write-Host "Found Item: $itemName" -ForegroundColor Green
                    $global:foundCount++
                    deleteBucketItem $itemName $itemSize $itemEtag $bucketName $itemDate
                    $global:itemsCount++
                }
            }
        }
    }
    $outputMessage = "Delete Completed, $global:itemsCount s3 items discovered and $global:itemsRemoved removed"
    Write-Host "$outputMessage" -ForegroundColor Yellow
}

# Delete an item in your S3 bucket
function deleteBucketItem($itemName, $itemSize, $itemEtag, $bucketName, $itemDate){
    if($prompt -eq "y"){
        # You selected to prompt for each item
        $myprompt = 'Do you want to delete "' + $itemName + '" (y/N)'
        $deleteMe = Read-Host -Prompt $myprompt
        # Check if you want to delete or not
        if($deleteMe -eq "y"){
            aws s3api delete-object --bucket $bucketName --key $itemName --profile $profileName
            $NewLine = "{0},{1},{2},{3},{4},{5}" -f "DELETED",$itemName,$bucketName,$itemSize,$itemEtag,$itemDate
            Write-Host "Deleted $itemName" -ForegroundColor Black -BackgroundColor Red
            $global:itemsRemoved++
        }
        else{
            $NewLine = "{0},{1},{2},{3},{4},{5}" -f "RETAINED",$itemName,$bucketName,$itemSize,$itemEtag,$itemDate
            Write-Host "Keeping $itemName" -ForegroundColor Black -BackgroundColor Green
        }
    }
    else{
        # You wanted an automated deletion routine
        aws s3api delete-object --bucket $bucketName --key $itemName --profile $profileName
        $NewLine = "{0},{1},{2},{3},{4},{5}" -f "DELETED",$itemName,$bucketName,$itemSize,$itemEtag,$itemDate
        Write-Host "Automatic mode: Deleted $itemName" -ForegroundColor Black -BackgroundColor Red
        $global:itemsRemoved++
    }
    $NewLine | add-content -path $global:outputFile
}

# File output generation routines - opening and header of the file
function CreateFileOutput {
    $theDate = Get-Date -Format "yyyyMMdd"
    $global:outputFile = "$theDate-s3-object-deletion.csv" # THE OUTPUT USER CSV FILE
    # WRITE THE HEADER LINE TO THE CSV
    $NewLine = "{0},{1},{2},{3},{4},{5}" -f "Status","Key","Bucket","Size","E-Tag","Last Modified"
    $NewLine | add-content -path $global:outputFile
    Write-Host "Creating Output File : $global:outputFile" -BackgroundColor Yellow -ForegroundColor Black
}

########################## MAIN SCRIPT RUN PHASE - FIRST LAUNCH RUNS HERE =============================>
Clear-Host
Write-Host "          .d8888b.            888  CloudHacker's            " -ForegroundColor Blue
Write-Host "         d88P  Y88b           888                           " -ForegroundColor Blue
Write-Host "              .d88P           888                           " -ForegroundColor Blue
Write-Host " .d8888b     8888     .d8888b 888  .d88b.   8888b.  888d888 " -ForegroundColor Blue
Write-Host "88K            Y8b.  d88P     888 d8P  Y8b      88b 888P   " -ForegroundColor Blue
Write-Host " Y8888b. 888    888  888      888 88888888 .d888888 888     " -ForegroundColor Blue
Write-Host "    X88 Y88b  d88P   Y88b.    888 Y8b.     888  888 888     " -ForegroundColor Blue
Write-Host "88888P    Y8888P       Y8888P 888   Y8888   Y888888 888     " -ForegroundColor Blue
Write-Host "                                                 v1.0.0" -ForegroundColor Blue

if($silent -eq 'y'){
    Write-Host "SILENT MODE: NO PROMPTING" -ForegroundColor Black -BackgroundColor Red
    if($output -eq 'y'){
        CreateFileOutput
    }
    enumerateGroups
}
else{
    $myprompt = "This is a destructive task - Do you want to continue this process (y/N)?"
    $goProcess = Read-Host -Prompt $myprompt
    # Check if you want to delete or not
    if($goProcess -eq "y"){
        Write-Host "Continuing...." -ForegroundColor Black -BackgroundColor Green
        Write-Host "BE CAREFUL WITH DELETING WHOLE FOLDER ITEMS!" -ForegroundColor Black -BackgroundColor Red
        CreateFileOutput
        enumerateItems
    }
    else{
        Write-Host "EXIT! Cancelling deletion routines." -ForegroundColor Red
    }
}