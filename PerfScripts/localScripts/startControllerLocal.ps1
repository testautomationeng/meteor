$props = $args[0]
$isDocker = $args[1]
$jmeterScriptPath = $args[2]
$jmeterScriptName = $args[3]
$jmeterPath = $args[4]
$controllerHost=$props.controller.host

Write-Host "Controller ${controllerHost} is being setup for ${jmeterScriptPath}/${jmeterScriptName}" -ForegroundColor Cyan

Write-Host "Copying Jmeter Setup on Controller " $controllerHost -ForegroundColor Cyan
.".\PerfScripts\common\runCommandOnServer.ps1" $controllerHost $props.controller.OS "cd ~;mkdir -p tmp;cd ~/tmp/; mkdir -p controller" $props.controller.privatekey $props.controller.username
#Copy Jmeter Setup to Server
.".\PerfScripts\common\copyOnServer.ps1" $props.controller.host $props.controller.os $jmeterPath "controller" $props.controller.privatekey $props.controller.username

Write-Host "Copying Jmeter Script File on Controller" -ForegroundColor Cyan
#Copy Jmeter Script file to Server     
.".\PerfScripts\common\copyOnServer.ps1" $props.controller.host $props.controller.os "${jmeterScriptPath}\${jmeterScriptName}" "controller" $props.controller.privatekey $props.controller.username
.".\PerfScripts\common\copyOnServer.ps1" $props.controller.host $props.controller.os "${jmeterScriptPath}\jmeterData.csv" "controller" $props.controller.privatekey $props.controller.username
.".\PerfScripts\common\copyOnServer.ps1" $props.controller.host $props.controller.os "${jmeterScriptPath}\jmeter.prop" "controller" $props.controller.privatekey $props.controller.username

if($isDocker){
    #Copy Dockerfile to Server     
    Write-Host "Setting up Docker on Controller..." -fore Cyan
    .".\PerfScripts\common\copyOnServer.ps1" $props.controller.host $props.controller.os ".\jmeter-docker\Dockerfile" "controller" $props.controller.privatekey $props.controller.username
    .".\PerfScripts\common\setupDocker.ps1" $props.controller.os $props.controller.host "client" $props.controller.privatekey $props.controller.username
    Write-Host "Starting Jmeter docker on Controller ..." -fore Cyan
    .".\PerfScripts\jmeterScripts\runJmeterScripts.ps1" ${jmeterScriptName} $true $props.loadgen.host ${controllerHost} $props.controller.privatekey $props.controller.username
}else{
    #run jmeter bat on controller
    .".\PerfScripts\common\runCommandOnServer.ps1" $props.controller.host $props.controller.OS "tar -xzf ~/tmp/controller/jmeterSetup.tar.gz -C ~/tmp/controller/" $props.controller.privatekey $props.controller.username
    Write-Host "Starting Jmeter Script on Controller ..." -fore Cyan
    .".\PerfScripts\jmeterScripts\runJmeterScripts.ps1" ${jmeterScriptName} $false $props.loadgen.host ${controllerHost} $props.controller.privatekey $props.controller.username
}
Write-Host "Getting results file on local Report folder" -ForegroundColor Cyan
.".\PerfScripts\common\getFromServer.ps1" $controllerHost $props.controller.os "outfile.jtl" "./Report/" "controller" $props.controller.privatekey $props.controller.username