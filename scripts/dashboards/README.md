# Automated Dashboard System

Generate base dashboards from parameters given or recreate previously generated dashboards.

Generating CloudWatch dashboards through simple menu-driven queries.

## Config File

The dashconfig.ps1 file contains some of the default settings for the display of widgets. Modify this file if you require base settings for widget sizes and locations.

The settings relate to the default position and size of the widgets. CloudWatch will try to automatically fit items into the space if values clash and sequentially display. As you generate your dashboard you can tailor the order of components.

## Script Operation

When the script launches you will be asked to confirm the AWS profile you wish to operate under. If using AWS SSO you will need to log in before running the script.

You are asked if you want to view the current dashboards on the account ( to make sure you do not clash with your naming ).

Enter a name for the board and give it a description ( which will also be used in a text widget at the top of the board ).


The Menu System then allows the generation of multiple items for each of the following:

1. Create Network Load Balancer Widget ( NLB )
2. Create Target Group Widget ( TG )
3. Create Elastic Kubernetes Service Widget ( EKS )
4. Create Elastic File System Widget ( EFS )
5. Create Elastic Compute Widget ( EC2 )
6. Create Logs Widget
7. Create S3 Bucket Widget 
8. Create RDS Widget


After adding items to each service a counter will increment next to the function name to denote how many of that item you will create at the end of the process. This helps you keep track of the quantity of infrastructure you'll be monitoring in that particular dashboard.

Finally, once you have completed the process, you can initiate the Run Generation option to generate the dashboard.

9. Run Generation


If all operates correctly you will be given a confirmation of the creation. If an error occurs in the process you will be provided with an error message and the JSON output in order to trouble-shoot should it be necessary.

# Re-Create Dashboards

If you want to recreate a dashboard you've already created ( dashboard code is saved to the root level of your git project folder ) you can use the ```buildDashboard.ps1``` script.

You will be prompted for the AWS profile, the full path location of the file, the new name of the dashboard and then the script will rebuild your CloudWatch dashboard.

This method allows you to quickly modify ARN's for items that may rotate instead of having to regenerate complicated dashboards again.