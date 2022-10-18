# AWS Budget and Cost Explorer

Output information around monthly costs.

Scripts to pull information related to budgets and expendature on the AWS accounts.

## Month To Date Costs

The [AWS Monthly Cost script](costs.ps1) can provide information for any AWS account you have a profile set up for ( and have authenticated to via aws sso / inserting credentials ). The script accepts parameters or you can interactively be prompted for them if you do not provide them on the command line.

**If you do not specify date ranges it will default to: CURRENT MONTH TO CURRENT DAY**

You can also request to be prompted for the date by adding the flag:  **-prompt y**

```
./costs.ps1 -profileName AWSProfileName -startDate YYYY-MM-DD -endDate YYYY-MM-DD -outputType table
```

Output types available: **table** (default setting when not specified) / **json** / **text** / **yaml**

*Example calls*
```
./costs.ps1 -profileName AWSProfileName -outputType json
```

```
./costs.ps1 -profileName AWSProfileName -startDate YYYY-MM-DD -outputType text
```

```
./costs.ps1 -profileName AWSProfileName -prompt y
```
To get a more informative breakdown, utilise the [month to date](costs.ps1) script.