# read config file
$propFile = Get-Content(".\config.json") | ConvertFrom-Json
$jmeterScriptPath=".\PerfScripts\jmeterScripts\"
$jmeterPath = ".\jmeter-docker\jmeterSetup.tar.gz"
$jmeterScriptName = $propFile.controller.jmeterfile

#download jmeter script from Git
#Write-Host "Started copying JMeter scripts from source control" -ForegroundColor Cyan
#call script to pull Jmeter scripts from Git and set path in ${jmeterScriptPath}
#Write-Host "JMeter Scripts copied on local from source control" -ForegroundColor Cyan

#setup jmeter script on local machine
Write-Host "Jmeter setup initiated" -ForegroundColor Cyan
.".\PerfScripts\jmeterScripts\setupJmeterScript.ps1" $propFile.threadSetup.threadCount $propFile.threadSetup.rampUpPeriod $propFile.threadSetup.loopCount $propFile.threadSetup.schedulerDuration $propFile.threadSetup.schedulerStartUpDelay $propFile.report.graphiteServer $propFile.report.graphitePort
Write-Host "Jmeter setup completed" -ForegroundColor Cyan
Write-Host "location of load generator " $prodFile.loadgen.location
# run jmeter script based on loadGenLocation
if ($propFile.loadgen.location -eq 'local'){
    write-host "Call Script for running jmeter on " $propFile.loadgen.host
    .".\PerfScripts\localScripts\startLoadGenLocal.ps1" $propFile $false $jmeterPath $jmeterScriptPath $jmeterScriptName
}elseif ($propFile.loadgen.location -eq 'local-docker'){
    write-host "Call Script for running jmeter on " $propFile.loadgen.host " using docker"
    .".\PerfScripts\localScripts\startLoadGenLocal.ps1" $propFile $true $jmeterPath $jmeterScriptPath $jmeterScriptName
}elseif($propFile.loadgen.location -eq 'cloud'){
    Write-Host "Setup load generators on Cloud"
    .".\PerfScripts\cloudScripts\startLoadGenOnCloud.ps1" $propFile.loadgen.cloud $false $jmeterPath $jmeterScriptPath $jmeterScriptName
}elseif($propFile.loadgen.location -eq 'cloud-docker'){
    Write-Host "Setup load generators on Cloud using docker "
    .".\PerfScripts\cloudScripts\startLoadGenOnCloud.ps1" $propFile.loadgen.cloud $true $jmeterPath $jmeterScriptPath $jmeterScriptName
}

# Start controller based on controllerLocation 
if ($propFile.controller.location -eq 'local'){    
    write-host "Calling Script to start jmeter on controller machine ${propFile.controller.host}"
    .".\PerfScripts\localScripts\startControllerLocal.ps1" $propFile $false $jmeterScriptPath $jmeterScriptName $jmeterPath
}elseif($propFile.controller.location -eq 'cloud'){
    write-host "Call Script for start jmeter server on controller machine on cloud " 
    .".\PerfScripts\cloudScripts\startControllerOnCloud.ps1" $propFile.controller.cloud $false $jmeterScriptPath $jmeterScriptName $jmeterPath
}elseif($propFile.controller.location -eq 'local-docker'){
    write-host "Calling Script to start jmeter server on controller machine using docker ${propFile.controller.host}"
    .".\PerfScripts\localScripts\startControllerLocal.ps1" $propFile $true $jmeterScriptPath $jmeterScriptName $jmeterPath
}elseif($propFile.controller.location -eq 'cloud-docker'){
    write-host "Call Script for start jmeter server on controller machine on cloud using docker "
    .".\PerfScripts\cloudScripts\startControllerOnCloud.ps1" $propFile.controller.cloud $true $jmeterScriptPath $jmeterScriptName $jmeterPath
}

#Start with clean up --kill jmeter processes in all machines
Write-Host "Started clean up activity..." -ForegroundColor Green
.".\PerfScripts\common\cleanUp.ps1" $propFile
