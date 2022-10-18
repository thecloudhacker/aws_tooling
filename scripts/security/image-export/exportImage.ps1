#######################################################################################################
# Export an AMI to an S3 bucket                                                                       #
#                                                                                                     #
# Script requires parameters passed to it for AMI ID, disk format, S3 bucket and AWS profile          #
# It will then generate a virtual machine image in the S3 bucket you have chosen                      #
#                                                                                                     #
# Expected parameters format:                                                                         #
# .\exportImage.ps1 -amiID 01234567 -diskFormat VMDK -s3Bucket MyExportBucket -profileName awsProfile #
#                                                                                                     #
# Export formats available:                                                                           #
#   VMDK (Stream-optimised ESX compatible with VMWare ESX and VM VSphere 4,5 & 6)                     #
#   VHD (Compatible with Citrix Xen and Microsoft Hyper-V virtualisation)                             #
#   Raw format                                                                                        #
#######################################################################################################

# Get parameters from the command line
param(
    $amiID,
    $diskFormat,
    $s3Bucket,
    $profileName
)

if(([string]::IsNullOrEmpty($amiID))){
    Write-Host "AMI ID Missing - Need an AMI to export" -ForegroundColor Red
    Exit
}

if(([string]::IsNullOrEmpty($diskFormat))){
    Write-Host "Disk Format Missing - select VMDK, VHD or raw" -ForegroundColor Red
    Exit
}

if(([string]::IsNullOrEmpty($s3Bucket))){
    Write-Host "S3 Bucket Missing - Need an output location" -ForegroundColor Red
    Exit
}

if(([string]::IsNullOrEmpty($profileName))){
    Write-Host "AWS Profile Missing - What account am I using?" -ForegroundColor Red
    Exit
}

Write-Host "Generating your request for an image in S3 bucket $s3Bucket in $diskFormat format" -ForegroundColor Black -BackgroundColor Yellow

# Generate the image in your chosen S3 bucket
aws ec2 export-image --image-id $amiID --disk-image-format $diskFormat --s3-export-location S3Bucket=$s3Bucket --profile $profileName --region eu-west-2

Write-Host "Check your S3 bucket in a few minutes time..."