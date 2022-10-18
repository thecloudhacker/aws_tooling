#######################################
#                                     
#     AWS Create Dashboard Script     
#  Description:
#     Generates CloudWatch            
#     Dashboards in AWS               
#     Uses dashconfig.ps1 for main    
#     settings around widgets.        
#                                     
#  Version: 1.0.1                  
#  Author: Rick Trotter
#  
#######################################



#### Set localised variables  ########

### Main JSON Construct Variable

$global:dashCode = ""
$global:nlbcount = 0;
$global:tgcount = 0;
$global:ekscount = 0;
$global:efscount = 0;
$global:ec2count = 0;
$global:logcount = 0;
$global:s3count = 0;
$global:rdscount = 0;

## Load in the variable file
. .\dashconfig.ps1


## Provide information to the user around exiting the listing of infrastructure when running
Write-Host "                     ┌┬┐┌─┐┌─┐┬ ┬┌─┐┌─┐┌┐┌" -ForegroundColor Yellow
Write-Host "                      ││├─┤└─┐├─┤│ ┬├┤ │││" -ForegroundColor Yellow
Write-Host "                     ─┴┘┴ ┴└─┘┴ ┴└─┘└─┘┘└┘" -ForegroundColor Yellow
Write-Host "  +--------------------------------------------------------------------------------+  " -BackgroundColor Blue -ForegroundColor Yellow
Write-Host "  |* Tip: Use q to exit any listing of infrastructure and drop to your selection  *|  " -BackgroundColor Blue -ForegroundColor Yellow
Write-Host "  |* Tip: The number of each monitor I will build is displayed on the main screen *|  " -BackgroundColor Blue -ForegroundColor Yellow
Write-Host "  +--------------------------------------------------------------------------------+  " -BackgroundColor Blue -ForegroundColor Yellow


########## --------------------------------------------------------------------------- GENERATION FUNCTIONS ----------------------------------------------------

function createNLB{
    Write-Host "  Building NLB Widgets" -ForegroundColor Green
        ## Verify the names of Network Load Balancer 
        $displayelb = Read-Host -Prompt 'View Load Balancers? y/N'
        if(-not ([string]::IsNullOrEmpty($displayelb)) -And $displayelb -ne 'n'){
            Write-Host "  READING AWS LOAD BALANCERS:" -BackgroundColor Red -ForegroundColor Black
            aws elbv2 describe-load-balancers --names --profile $profileName
        }
        ## Prompt for the name
        $myloadbalancer = Read-Host -Prompt 'Which Network Load Balancer?'
        if(-not ([string]::IsNullOrEmpty($myloadbalancer))){
            $loadBalancerName = $myloadbalancer
            Write-Host "  Using $loadBalancerName " -BackgroundColor Yellow -ForegroundColor Black
            ##  Check if dashCode has previous items, if so add a comma to keep the JSON correct
            $global:dashCode += ','
            # Add in the items to widget selection
            $global:dashCode += '{
                \"type\":\"metric\",
                \"x\":' + $NLB_WIDGET_X + ',
                \"y\":' + $NLB_WIDGET_Y + ',
                \"width\":' + $NLB_WIDGET_WIDTH + ',
                \"height\":' + $NLB_WIDGET_HEIGHT + ',
                \"properties\":{
                   \"metrics\":[
                      [
                         \"AWS/NetworkELB\",
                         \"PeakPacketsPerSecond\",
                         \"LoadBalancer\",
                         \"' + $loadBalancerName + '\",
                         \"AvailabilityZone\",
                         \"eu-west-2a\"
                      ],
                      [ \"...\", \"eu-west-2b\"],
                      [ \"...\", \"eu-west-2c\"]
                   ],
                   \"period\": 300,
                   \"stat\": \"Maximum\",
                   \"region\": \"eu-west-2\",
                   \"view\": \"timeSeries\",
                   \"stacked\": false,
                   \"title\": \"ELB Packets Per Second\"
                 }
                }'
                $global:nlbcount ++
        }
        else{
            Write-Host "  Cancelling Network Load Balancer - none specified" -ForegroundColor Red 
        }
    # Wait a second before launching menu
    Start-Sleep -s 1
    Clear-Host
    runMyMenu
}



function createTargetGroup{
    Write-Host "  Building Target Group Widgets" -ForegroundColor Green
        ## Verify the names of Network Load Balancer 
        $displaytg = Read-Host -Prompt 'View Target Groups? y/N'
        if(-not ([string]::IsNullOrEmpty($displayelb)) -And $displaytg -ne 'n'){
            Write-Host "  READING AWS TARGET GROUPS:" -BackgroundColor Red -ForegroundColor Black
            aws elbv2 describe-target-groups --profile $profileName
        }
        ## Prompt for the name
        $mytargetgroup = Read-Host -Prompt 'Which Target Group?'
        if(-not ([string]::IsNullOrEmpty($mytargetgroup))){
            $targetGroupName = $mytargetgroup
            Write-Host "  Using $targetGroupName " -BackgroundColor Yellow -ForegroundColor Black

            $myloadbalancer = Read-Host -Prompt "Which Load Balancer? ( Default is:  $loadBalancerName )"
            if(-not ([string]::IsNullOrEmpty($myloadbalancer))){
                $loadBalancerName = $myloadbalancer
            }
            Write-Host "  Using $loadBalancerName " -BackgroundColor Yellow -ForegroundColor Black

            # Add in the items to widget selection
            ##  Check if dashCode has previous items, if so add a comma to keep the JSON correct
            $global:dashCode += ','
            ##  Target Group Code for Healthy Hosts
            $global:dashCode += '{
                \"type\":\"metric\",
                \"x\":' + $TG_WIDGET_X + ',
                \"y\":' + $TG_WIDGET_Y + ',
                \"width\":' + $TG_WIDGET_WIDTH + ',
                \"height\":' + $TG_WIDGET_HEIGHT + ',
                \"properties\":{
                   \"metrics\":[
                      [
                         \"AWS/NetworkELB\",
                         \"HealthyHostCount\",
                         \"TargetGroup\",
                         \"' + $targetGroupName + '\",
                         \"LoadBalancer\",
                         \"' + $loadBalancerName + '\",
                         \"AvailabilityZone\",
                         \"eu-west-2a\"
                      ],
                      [ \"...\", \"eu-west-2b\"],
                      [ \"...\", \"eu-west-2c\"]
                   ],
                   \"period\": 300,
                   \"stat\": \"Maximum\",
                   \"region\": \"eu-west-2\",
                   \"view\": \"singleValue\",
                   \"stacked\": false,
                   \"title\": \"Healthy Host Count : ' + $targetGroupName + '\"
                 }
                }'
            ## Target Group Code for UnHealthy Hosts
            $global:dashCode += ','
            $global:dashCode += '{
                \"type\":\"metric\",
                \"x\":' + $TG_WIDGET_X + ',
                \"y\":' + $TG_WIDGET_Y + ',
                \"width\":' + $TG_WIDGET_WIDTH + ',
                \"height\":' + $TG_WIDGET_HEIGHT + ',
                \"properties\":{
                   \"metrics\":[
                      [
                         \"AWS/NetworkELB\",
                         \"UnHealthyHostCount\",
                         \"TargetGroup\",
                         \"' + $targetGroupName + '\",
                         \"LoadBalancer\",
                         \"' + $loadBalancerName + '\",
                         \"AvailabilityZone\",
                         \"eu-west-2a\"
                      ],
                      [ \"...\", \"eu-west-2b\"],
                      [ \"...\", \"eu-west-2c\"]
                   ],
                   \"period\": 300,
                   \"stat\": \"Maximum\",
                   \"region\": \"eu-west-2\",
                   \"view\": \"singleValue\",
                   \"stacked\": false,
                   \"title\": \"UnHealthy Host Count : ' + $targetGroupName + '\"
                 }
                }'
            $global:tgcount ++
        }
        else{
            Write-Host "  Cancelling Target Group - none specified" -ForegroundColor Red 
        }
    # Wait a second before launching menu
    Start-Sleep -s 1
    Clear-Host
    runMyMenu
}


function createEKS{
    Write-Host "  Building EKS Widgets" -ForegroundColor Green
        ## Verify the name of Elastic Kubernetes Service
        $displayeks = Read-Host -Prompt 'View ASGs? y/N'
        if(-not ([string]::IsNullOrEmpty($displayeks)) -And $displayeks -ne 'n'){
            Write-Host "  READING AWS ASG:" -BackgroundColor Red -ForegroundColor Black
            aws autoscaling describe-auto-scaling-groups --profile $profileName
        }
        $myekscluster = Read-Host -Prompt 'Which EKS Auto Scale Group?'
        if(-not ([string]::IsNullOrEmpty($myekscluster))){
            $EKSClusterName = $myekscluster
            Write-Host "  Using ASG $EKSClusterName " -BackgroundColor Yellow -ForegroundColor Black
            # Add in the items to widget selection
            ##  Check if dashCode has previous items, if so add a comma to keep the JSON correct
            $global:dashCode += ','
            ##  EKS Group Code - A Mix of EC2 Data to display some EKS information
            $global:dashCode += '{
                \"type\":\"metric\",
                \"x\":' + $EKS_WIDGET_X + ',
                \"y\":' + $EKS_WIDGET_Y + ',
                \"width\":' + $EKS_WIDGET_WIDTH + ',
                \"height\":' + $EKS_WIDGET_HEIGHT + ',
                \"properties\":{
                   \"metrics\":[
                      [
                         \"AWS/EC2\",
                         \"EBSIOBalance%\",
                         \"AutoScalingGroupName\",
                         \"' + $EKSClusterName + '\"
                      ],
                      [ \".\", \"CPUUtilization\", \".\",\".\", { \"stat\": \"Maximum\" }]
                   ],
                   \"period\": 300,
                   \"stat\": \"Average\",
                   \"region\": \"eu-west-2\",
                   \"view\": \"timeSeries\",
                   \"stacked\": false,
                   \"title\": \"EKS ASG : ' + $EKSClusterName + '\"
                 }
                }'
                $global:ekscount ++
        }
        else{
            Write-Host "  Cancelling EKS - none specified" -ForegroundColor Red 
        }
    # Wait a second before launching menu
    Start-Sleep -s 1
    Clear-Host
    runMyMenu
}

function createEFS{
    Write-Host "  Building EFS Widgets" -ForegroundColor Green
        ## Verify the name of Elastic File System
        $displayefs = Read-Host -Prompt 'View EFS mounts? y/N'
        if(-not ([string]::IsNullOrEmpty($displayefs)) -And $displayefs -ne 'n'){
            Write-Host "  READING AWS EFS:" -BackgroundColor Red -ForegroundColor Black
            aws efs describe-access-points --profile $profileName
        }
        $myefs = Read-Host -Prompt 'Which EFS?'
        if(-not ([string]::IsNullOrEmpty($myefs))){
            $EFSName = $myefs
            Write-Host "  Using $EFSName " -BackgroundColor Yellow -ForegroundColor Black
            # Add in the items to widget selection
            ##  Check if dashCode has previous items, if so add a comma to keep the JSON correct
            $global:dashCode += ','
            ##  EKS Group Code - A Mix of EC2 Data to display some EKS information
            $global:dashCode += '{
                \"type\":\"metric\",
                \"x\":' + $EFS_WIDGET_X + ',
                \"y\":' + $EFS_WIDGET_Y + ',
                \"width\":' + $EFS_WIDGET_WIDTH + ',
                \"height\":' + $EFS_WIDGET_HEIGHT + ',
                \"properties\":{
                   \"metrics\":[
                    [ \"AWS/EFS\", \"DataReadIOBytes\", \"FileSystemId\", \"' + $EFSName + '\" ],
                    [ \".\", \"DataWriteIOBytes\", \".\", \".\" ]
                   ],
                   \"region\": \"eu-west-2\",
                   \"view\": \"timeSeries\",
                   \"stacked\": false,
                   \"title\": \"EFS I/O: ' + $EFSName + '\"
                 }
                }'
            $global:efscount ++
        }
        else{
            Write-Host "  Cancelling EFS - none specified" -ForegroundColor Red 
        }
    # Wait a second before launching menu
    Start-Sleep -s 1
    Clear-Host
    runMyMenu
}

function createEC2{
    Write-Host "  Building EC2 Widgets" -ForegroundColor Green
        ## Verify the name of EC2 Instance to add
        $displayec2 = Read-Host -Prompt 'View instances? y/N'
        if(-not ([string]::IsNullOrEmpty($displayec2)) -And $displayec2 -ne 'n'){
            Write-Host "  READING AWS EC2:" -BackgroundColor Red -ForegroundColor Black
            aws ec2 describe-instances --profile $profileName
        }
        
        $myec2 = Read-Host -Prompt 'Which EC2 instance ( Instance ID )?'
        if(-not ([string]::IsNullOrEmpty($myec2))){
            $ec2Name = $myec2
            Write-Host "  Using $ec2Name " -BackgroundColor Yellow -ForegroundColor Black
            # Add in the items to widget selection
            ##  Check if dashCode has previous items, if so add a comma to keep the JSON correct
            $global:dashCode += ','
            ##  EC2 Instance Code
            $global:dashCode += '{
                \"type\":\"metric\",
                \"x\":' + $EC2_WIDGET_X + ',
                \"y\":' + $EC2_WIDGET_Y + ',
                \"width\":' + $EC2_WIDGET_WIDTH + ',
                \"height\":' + $EC2_WIDGET_HEIGHT + ',
                \"properties\":{
                   \"metrics\":[
                      [
                         \"AWS/EC2\",
                         \"CPUUtilization\",
                         \"InstanceId\",
                         \"' + $ec2Name + '\"
                      ]
                   ],
                   \"period\": 300,
                   \"stat\": \"Maximum\",
                   \"region\": \"eu-west-2\",
                   \"view\": \"timeSeries\",
                   \"stacked\": false,
                   \"title\": \"EC2 Instance ( ' + $ec2Name + ' ) CPU Utilization\"
                 }
                }'
                $global:ec2count ++
        }
        else{
            Write-Host "  Cancelling EC2 - none specified" -ForegroundColor Red 
        }
    # Wait a second before launching menu
    Start-Sleep -s 1
    Clear-Host
    runMyMenu
}

function createLogs{
    Write-Host "  Building Log Widgets" -ForegroundColor Green
        ## Verify the name of Log to add
        $mylog = Read-Host -Prompt 'Which Log Source? ( Name )'
        if(-not ([string]::IsNullOrEmpty($mylog))){
            $logName = $mylog
            Write-Host "  Using $logName " -BackgroundColor Yellow -ForegroundColor Black
            # Add in the items to widget selection
            ##  Check if dashCode has previous items, if so add a comma to keep the JSON correct
            $global:dashCode += ','
            ##  Log Group Code
            # Fix Log Name with the extra quotes
            $logNameFixed = "'" + $logName + "'"
            $global:dashCode += '{
                \"type\": \"log\",
                \"x\":' + $LOG_WIDGET_X + ',
                \"y\":' + $LOG_WIDGET_Y + ',
                \"width\":' + $LOG_WIDGET_WIDTH + ',
                \"height\":' + $LOG_WIDGET_HEIGHT + ',
                \"properties\": {
                    \"query\": \"SOURCE ' + $logNameFixed + ' | fields @timestamp, @message\n| sort @timestamp desc\n| limit 20\",
                    \"region\": \"eu-west-2\",
                    \"stacked\": false,
                    \"view\": \"table\",
                    \"title\": \"' + $logName + ' Log Output\"
                }
            }'
            $global:logcount ++
        }
        else{
            Write-Host "  Cancelling EC2 - none specified" -ForegroundColor Red 
        }
    # Wait a second before launching menu
    Start-Sleep -s 1
    Clear-Host
    runMyMenu
}

function createS3{
    Write-Host "  Building S3 Widgets" -ForegroundColor Green
        ## Verify the name of Bucket to add
        $mys3 = Read-Host -Prompt 'Which S3 Bucket? ( Name )'
        if(-not ([string]::IsNullOrEmpty($mys3))){
            $s3Name = $mys3
            Write-Host "  Using $s3Name " -BackgroundColor Yellow -ForegroundColor Black
            # Add in the items to widget selection
            ##  Check if dashCode has previous items, if so add a comma to keep the JSON correct
            $global:dashCode += ','
            ##  S3 Bucket Code
            $global:dashCode += '{
                \"type\": \"metric\",
                \"x\":' + $S3_WIDGET_X + ',
                \"y\":' + $S3_WIDGET_Y + ',
                \"width\":' + $S3_WIDGET_WIDTH + ',
                \"height\":' + $S3_WIDGET_HEIGHT + ',
                \"properties\": {
                    \"metrics\": [
                        [ \"AWS/S3\", \"NumberOfObjects\", \"StorageType\", \"AllStorageTypes\", \"BucketName\", \"' + $s3Name + '\", { \"period\": 86400 } ],
                        [ \".\", \"BucketSizeBytes\", \".\", \"StandardStorage\", \".\", \".\", { \"period\": 86400 } ]
                    ],
                    \"region\": \"eu-west-2\",
                    \"stacked\": false,
                    \"view\": \"timeSeries\",
                    \"title\": \"' + $s3Name + ' Bucket\"
                }
            }'
            $global:s3count ++
        }
        else{
            Write-Host "  Cancelling S3 - none specified" -ForegroundColor Red 
        }
    # Wait a second before launching menu
    Start-Sleep -s 1
    Clear-Host
    runMyMenu
}


function createRDS{
    Write-Host "  Building RDS Widgets" -ForegroundColor Green
        ## Verify the name of RDS to add
        $myrds = Read-Host -Prompt 'Which RDS DB? ( Name )'
        if(-not ([string]::IsNullOrEmpty($myrds))){
            $rdsName = $myrds
            Write-Host "  Using $rdsName " -BackgroundColor Yellow -ForegroundColor Black
            # Add in the items to widget selection
            ##  Check if dashCode has previous items, if so add a comma to keep the JSON correct
            $global:dashCode += ','
            ##  RDS Bucket Code
            $global:dashCode += '{
                \"type\": \"metric\",
                \"x\":' + $RDS_WIDGET_X + ',
                \"y\":' + $RDS_WIDGET_Y + ',
                \"width\":' + $RDS_WIDGET_WIDTH + ',
                \"height\":' + $RDS_WIDGET_HEIGHT + ',
                \"properties\": {
                    \"metrics\": [
                        [ \"AWS/RDS\", \"ReadLatency\", \"DBInstanceIdentifier\", \"' + $rdsName + '\", { \"label\": \"ReadLatency\" } ],
                        [ \".\", \"WriteLatency\", \".\", \".\", { \"label\": \"WriteLatency\" } ]
                    ],
                    \"region\": \"eu-west-2\",
                    \"stacked\": false,
                    \"stat\": \"Maximum\",
                    \"view\": \"timeSeries\",
                    \"title\": \"' + $rdsName + ' Latency\"
                }
            }'
            $global:rdscount ++
        }
        else{
            Write-Host "  Cancelling RDS - none specified" -ForegroundColor Red 
        }
    # Wait a second before launching menu
    Start-Sleep -s 1
    Clear-Host
    runMyMenu
}

function generateDashboard{
    ######### Generate the Dashboard from the components selected
    Write-Host '  -[ You need to complete all build steps before continuing ]-' -ForegroundColor Black -BackgroundColor Red
    $readyToBuild = Read-Host -Prompt 'Ready to build? Y/n'
    if(-not ([string]::IsNullOrEmpty($readyToBuild)) -And $readyToBuild -ne 'n'){
        Write-Host "  Building..." -ForegroundColor Black -BackgroundColor Yellow
        ## Collate all the Widgets with a wrapper
        $fullContextCode = '{
            \"start\": \"-PT6H\",
            \"periodOverride\": \"inherit\",
            \"widgets\": [' + $global:dashCode + ']}'
        ## Run the output to AWS to build the dashboard
        if(aws cloudwatch put-dashboard --dashboard-name $dashboardName --dashboard-body "$fullContextCode"  --profile $profileName){
            Write-Host '  Process Complete ' -ForegroundColor Black -BackgroundColor Green
            # Write JSON to the disk
            $outputFile = ".\$dashboardName.txt"
            Out-File -FilePath $outputFile -InputObject $fullContextCode
            Write-Host "  Dashboard Output Written to $outputFile" -ForegroundColor Black -BackgroundColor Green
        }
        else{
            Write-Host '  SYSTEM PANIC! SOMETHING WENT WRONG' -ForegroundColor Black -BackgroundColor Red
            # Give JSON Output that might have caused the panic
            Write-Host "+--------------------------------------------------------------------------+" -ForegroundColor Green
            Write-Host $fullContextCode -ForegroundColor Red
            Write-Host "+--------------------------------------------------------------------------+" -ForegroundColor Green
        }
    }
    else{
        Write-Host '   CANCELLING! - USER NOT READY' - -ForegroundColor Black -BackgroundColor Red
    }
    # Wait a second before launching menu
    Start-Sleep -s 1
    Clear-Host
    runMyMenu
}

#
# Create fancy selection menu function
#
Function MenuMaker{
    param(
        [parameter(Mandatory=$true)][String[]]$Selections,
        [switch]$IncludeExit,
        [string]$Title = $null
        )
    Write-Host "  -------------- $dashboardName  --------------" -BackgroundColor Yellow -ForegroundColor Black
    $Width = if($Title){$Length = $Title.Length;$Length2 = $Selections|%{$_.length}|Sort -Descending|Select -First 1;$Length2,$Length|Sort -Descending|Select -First 1}else{$Selections|%{$_.length}|Sort -Descending|Select -First 1}
    $Buffer = if(($Width*1.5) -gt 78){[math]::floor((78-$width)/2)}else{[math]::floor($width/4)}
    if($Buffer -gt 6){$Buffer = 6}
    $MaxWidth = $Buffer*2+$Width+$($Selections.count).length+2
    $Menu = @()
    $Menu += "╔"+"═"*$maxwidth+"╗"
    if($Title){
        $Menu += "║"+" "*[Math]::Floor(($maxwidth-$title.Length)/2)+$Title+" "*[Math]::Ceiling(($maxwidth-$title.Length)/2)+"║"
        $Menu += "╟"+"─"*$maxwidth+"╢"
    }
    For($i=1;$i -le $Selections.count;$i++){
        $Item = "$(if ($Selections.count -gt 9 -and $i -lt 10){" "})$i`. "
        $Menu += "║"+" "*$Buffer+$Item+$Selections[$i-1]+" "*($MaxWidth-$Buffer-$Item.Length-$Selections[$i-1].Length)+"║"
    }
    If($IncludeExit){
        $Menu += "║"+" "*$MaxWidth+"║"
        $Menu += "║"+" "*$Buffer+"x - Exit"+" "*($MaxWidth-$Buffer-8)+"║"
    }
    $Menu += "╚"+"═"*$maxwidth+"╝"
    $menu
}
#
# Launch the main menu
#
Function runMyMenu{
    Do{
        MenuMaker -Selections "Create NLB ($global:nlbcount)","Create Target Group ($global:tgcount)","Create EKS ($global:ekscount)","Create EFS ($global:efscount)","Create EC2 ($global:ec2count)","Create Logs ($global:logcount)","Create S3 ($global:s3count)","Create RDS ($global:rdscount)","Run Generation" -Title 'Monitor Types' -IncludeExit
        $Response = Read-Host "Select action"
    }While($Response -notin 1,2,3,4,5,6,7,8,9,'x')
    Switch($Response){
        1 {
            # Create NLB
            Clear-Host
            createNLB
          }
        2 {
            # Create Target Group
            Clear-Host
            createTargetGroup
          }
        3 {
            # Create EKS
            Clear-Host
            createEKS
          }
        4 {
            # Create EFS
            Clear-Host
            createEFS
          }
        5 {
            # Create EC2
            Clear-Host
            createEC2
          }
        6 {
            # Create Logs
            Clear-Host
            createLogs
          }
        7 {
            # Create S3
            Clear-Host
            createS3
          }
        8 {
            # Create RDS
            Clear-Host
            createRDS
          }
        9 {
            # Generate The System
            Clear-Host
            generateDashboard
          }
        x {
            # Exit
        }
    }
}
########## --------------------------------------------------------------------------- END GENERATION FUNCTIONS ----------------------------------------------------


# Verify The AWS Profile to use
$myprompt = 'Which AWS profile? ( default is: ' + $profileName + ' )'
    # Check which profile to use
    $profileChoice = Read-Host -Prompt $myprompt
    # Check for what profile - if an entry given update the default
    if(-not ([string]::IsNullOrEmpty($profileChoice))){
        $profileName = $profileChoice
    }


# Display current dashboards?
$myprompt = 'Show current Dashboards in this account? y/N'
    # Check which profile to use
    $dashChoice = Read-Host -Prompt $myprompt
    # Check for what profile - if an entry given update the default
    if(-not ([string]::IsNullOrEmpty($dashChoice)) -And $dashChoice -ne 'n'){
        aws cloudwatch list-dashboards --profile $profileName
    }

# Set the dashboard name for AWS and a description to aid staff viewing it.

$mydashboard = Read-Host -Prompt 'Name for the new Dashboard?'
    if(-not ([string]::IsNullOrEmpty($mydashboard))){
        $dashboardName = $mydashboard
    }
$mydashboarddescription = Read-Host -Prompt 'Dashboard Description?'
    if(-not ([string]::IsNullOrEmpty($mydashboarddescription))){
        $dashboardDescription = $mydashboarddescription
    }

Write-Host "  Creating $dashboardName " -BackgroundColor Yellow -ForegroundColor Black

## Create the Description Widget
$global:dashCode += '{
    \"type\": \"text\",
    \"x\":' + $TITLE_WIDGET_X + ',
    \"y\":' + $TITLE_WIDGET_Y + ',
    \"width\":' + $TITLE_WIDGET_WIDTH + ',
    \"height\":' + $TITLE_WIDGET_HEIGHT + ',
    \"properties\": {
        \"markdown\": \"# ' + $dashboardName +'\n' + $dashboardDescription + '\"
    }
    }'


# Wait two seconds before launching menu
Start-Sleep -s 2
## Launch the Menu System
Clear-Host
runMyMenu