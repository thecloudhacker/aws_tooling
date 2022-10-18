
## Provide information to the user around exiting the listing of infrastructure when running
Write-Host "                     ┌┬┐┌─┐┌─┐┬ ┬┌─┐┌─┐┌┐┌" -ForegroundColor Yellow
Write-Host "                      ││├─┤└─┐├─┤│ ┬├┤ │││" -ForegroundColor Yellow
Write-Host "                     ─┴┘┴ ┴└─┘┴ ┴└─┘└─┘┘└┘" -ForegroundColor Yellow
Write-Host "     +-----------------------------------------------------------+  " -BackgroundColor Blue -ForegroundColor Yellow
Write-Host "     |   LOAD IN A PRE-BUILT DASHBOARD ALREADY STORED ON DISK    |  " -BackgroundColor Blue -ForegroundColor Yellow
Write-Host "     +-----------------------------------------------------------+  " -BackgroundColor Blue -ForegroundColor Yellow




## Primary generation routine used after data collection
function generateDashboard($myfilename, $dashboardName, $profileName){
    ######### Generate the Dashboard from the components selected
    $readyToBuild = Read-Host -Prompt 'Ready to build? Y/n'
    if(-not ([string]::IsNullOrEmpty($readyToBuild)) -And $readyToBuild -ne 'n'){
        Write-Host "  Loading File...[ $myfilename ]" -ForegroundColor Black -BackgroundColor Yellow
        $fullContextCode = Get-Content -Raw -Path $myfilename
        Write-Host "  Building... [ $dashboardName ]" -ForegroundColor Black -BackgroundColor Yellow
        ## Run the output to AWS to build the dashboard
        if(aws cloudwatch put-dashboard --dashboard-name "$dashboardName" --dashboard-body "$fullContextCode" --profile $profileName ){
            Write-Host '  Process Complete ' -ForegroundColor Black -BackgroundColor Green
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
    
}

##
## PRIMARY RUN CONTROL MECHANISMS
##

# Verify The AWS Profile to use
$myprompt = 'Which AWS profile? ( default is: ' + $profileName + ' )'
    # Check which profile to use
    $profileChoice = Read-Host -Prompt $myprompt
    # Check for what profile - if an entry given update the default
    if(-not ([string]::IsNullOrEmpty($profileChoice))){
        $profileName = $profileChoice
    }

# Verify the name of the board to create
$myprompt = 'What do you want the board to be called?'
$myboardname = Read-Host -Prompt $myprompt
if(-not ([string]::IsNullOrEmpty($myboardname))){
    $dashboardName = $myboardname
}
else{
    Write-Host "Missing Dashboard Name - Exiting" -ForegroundColor Red
    exit 1
}

$myprompt = 'What is the filename? ( provide full path )'
$myfilename = Read-Host -Prompt $myprompt
if(-not ([string]::IsNullOrEmpty($myfilename))){
    $fileToLoad = $myfilename
}
else{
    Write-Host "Missing Filename - Exiting" -ForegroundColor Red
    exit 1
}


generateDashboard $fileToLoad $dashboardName $profileName

