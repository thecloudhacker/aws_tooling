# AWS AMI Export Routines

In order to download an image from AWS, you first need to generate an AMI from your running system. You can do this through the main interface and select the "no reboot" option to ensure that you take a live cut ( which can be used for forensics or cloning systems ).

## Pre-Requisits

Before you can undertake the export task on an AWS account, you need to first generate a bucket that will hold the exported data, generate the IAM role and policy and then run the export routine ( which will operate as a background task ).

## Create the S3 Bucket

First you need to ensure you have a bucket available in the account in order to receive the exported images. You might already have one that you can utilise, but if not - you can generate one by using the following script:

```.\createExportBucket.ps1 {export bucket name} {aws profile}```


## Create the IAM Role and Policy

In order for the export script to run you require a role and policy that can be assumed by the script. This only needs to be undertaken **once** on your account unless you've removed the role and policy:

```.\createRoles.ps1 {aws profile}```


## Export the Image

Finally, you are ready to export the image from the AWS AMI format into your chosen Virtual Machine Image format:

```.\exportImage.ps1 -amiID 01234567 -diskFormat {VMDK/VHD} -s3Bucket MyExportBucket -profileName awsProfile```


### Checking status of the task
This process will take a while depending on the size of the disk image. You can verify the status by taking the "ExportImageTaskId" ID given in the exportImage output and plugging it into this command in place of the export-ami-0123456789 entry:

```aws ec2 describe-export-image-tasks --export-image-task-ids export-ami-0123456789 --profile {your AWS Profile} --region eu-west-2```


### Formats Available to download
- VMDK is Stream-optimised ESX-compatible with VMWare ESX and VM VSphere 4, 5 & 6
- VHD is Compatible with Citrix Xen and Microsoft Hyper-V virtualisation ( good for downloading and testing locally on your laptop )


## Additional files within this folder

The role-policy.json and trust-policy.json are used by the generate IAM Role & policy script. 