# Maintenance Scripts

Scripts that can be used to maintain AWS systems, undertake regular tasks or clear-up routines after doing development work.

## Logs

[Clearing Logs - logclear.ps1](logclear.ps1)

Deletes log groups - either all but an exclusion list, or those matching a pattern provided by the user. You can run in an automated more or interactive prompting.

```.\logclear.ps1 -profileName myAWSprofile -pattern lambda -output y -prompt y -silent n```

If you do not set the prompt and set silent to y then YOU WILL NOT BE PROMPTED AND THE DESTRUCTION WILL COMMENCE!


## S3

[Clearing S3 Buckets - s3clear.ps1](s3clear.ps1)

Deletes items from an S3 bucket in it's entirety, or those that are before a specified date. This can be interactive or automated.

```./s3clear.ps1 -profile myAWSprofile -beforedate 2022-11-01 -prompt y -bucketName myAWSbucket```

- If you omit the prompt confirmation option the script will run in automatic mode and begin deleting before the date. 
- If you omit the before date it will remove everything from the bucket. 
- If you run the delete process be very careful with folder items as they are unable to differentiate from file items ( this is especially important when running in AUTOMATIC mode with no prompting).
- An output log of what has been deleted is produced in the script run directory so you have a record of the events.