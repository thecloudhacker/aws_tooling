#############################################
# Create a bucket for the backup to use     #
#                                           #
# Requires bucket name and profile to use   #
#############################################


# Get parameters from the command line
param(
    $s3Bucket,
    $profileName
)

if(([string]::IsNullOrEmpty($s3Bucket))){
    Write-Host "S3 Bucket Name Missing" -ForegroundColor Red
    Exit
}

if(([string]::IsNullOrEmpty($profileName))){
    Write-Host "AWS Profile Missing - What account am I using?" -ForegroundColor Red
    Exit
}

Write-Host "Creating bucket '$s3Bucket' locked in eu-west-2" -ForegroundColor Black -BackgroundColor Green
# Create the bucket
aws s3api create-bucket --bucket $s3Bucket --region eu-west-2 --object-ownership BucketOwnerEnforced --create-bucket-configuration LocationConstraint=eu-west-2 --profile $profileName 

Write-Host "Action Complete"
