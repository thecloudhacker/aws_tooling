# Cognito Users

Create a CSV file with a list of users who have and who have not accessed your system using Cognito.

## Operation

Run the script:

```
./get_user_list.ps1
```

When prompted, enter which AWS profile you want to use for the connection ( there is a default set of "default" )

When prompted, enter which Cognito Pool ID you want to utilise.

The script will generate a file with the list of users who exist on the system. Once this initial list has been generated, it subsequently looks for activity by that account before writing the information to a CSV format file.

This can be used to subsequently generate reports in Excel. 