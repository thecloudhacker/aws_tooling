param($ctrl='share', $ami, $account, $snap, $awsprofile)
#
# AMI Control Mechanism
# Share, Delete and Find images on AWS
#

Write-Host "=============== AMI and Snapshot Control Mechanism ==============`n"
Write-Host "v 1.0 : Author R. Trotter : Check Github Docs for Help`n"
Write-Host "=================================================================`n`n"
# Ensure an AMI ID is present
if ($ami -eq $null) {
    $ami = read-host -Prompt "Please enter an AMI ID" 
}
# Verify the AWS Profile to use - set default if nothing specified
if ($awsprofile -eq $null) {
    $awsprofile = "default" 
}


#
# ----------------------- Check what control mechanism is being requested ----------------------------
#

# =============  SHARE AN AMI  =============
if ($ctrl -eq 'share') {
    
    Write-Host "Sharing Image : $ami"
    if ($account -eq $null) {
        $account = read-host -Prompt "Please enter an ACCOUNT ID you wish to allow them to use the image" 
    }
    # Modify the permissions on the image attributes
    aws ec2 modify-image-attribute --image-id $ami --launch-permission "Add=[{UserId=$account}] --profile $awsprofile"

    Write-Host "Share Permissions Set`n`n"
}



# =============  REMOVE AN ACCOUNT'S ACCESS FROM AN AMI  =============  
if ($ctrl -eq 'remove') {
    
    Write-Host "Removing Permissions on image ( $ami ) for user $account" 
    aws ec2 modify-image-attribute --image-id $ami --launch-permission "Remove=[{UserId=$account}] --profile $awsprofile"
    Write-Host "Image Permissions Removed`n`n"
}



# =============  DELETE AN AMI  =============  
if ($ctrl -eq 'delete') {
    
    Write-Host "Removing Image : $ami`n"
    # When deleting we need to loop through all of the volumes to remove the orphan'd shapshots
    $imageToDelete = aws ec2 describe-images --image-id $ami
    $count = $imageToDelete[0].BlockDeviceMapping.Count 
     $imageSnapshot = @() 
     for ($i=0; $i -lt $count; $i++) { 
         $snapId = $imageToDelete[0].BlockDeviceMapping[$i].Ebs | foreach {$_.SnapshotId} 
         $imageSnapshot += $snapId 
     } 
    Write-Host "Unregistering" $ami 
    aws ec2 deregister-image --image-id $ami 
     foreach ($item in $imageSnapshot) { 
         Write-Host 'Removing' $item 
         aws ec2 delete-snapshot --snapshot-id $item 
     }

    Write-Host "`n`nImage Removal complete`n`n"
}



# =============  QUERY AN AMI =============  
if ($ctrl -eq 'query') {
    
    Write-Host "Query Image : $ami"
    aws ec2 describe-images --image-ids $ami

}




# =============  QUERY AN AMI =============  
if ($ctrl -eq 'reset') {
    
    Write-Host "Reset Image : $ami ?"
    $pleaseconfirm = read-host -Prompt "y/N ?"
    if ($pleaseconfirm -eq 'y') {
        Write-Host "OK, Resetting Permissions"
        aws ec2 reset-image-attribute --image-id $ami --attribute launchPermission --profile $awsprofile
        Write-Host "Completed."
    }
    else{
        Write-Host "OK, CANCELLING RESET. No Action taken."
    }
}

