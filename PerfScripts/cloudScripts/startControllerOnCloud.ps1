$props = $args[0]
$isdocker = $args[1]
$jmeterScriptpath = $args[2]
$jmeterScriptName = $args[3]
$jmeterpath = $args[4]
$tmpfolder="~/tmp/controller/"
$remoteLoadGen = Get-Content -Path ".\PerfScripts\cloudScripts\loadgenlist.txt"

if($props.createinstance -eq "true"){
    $controllerHost="jmeter-controller"
    Write-Host "Controller ${controllerHost} is being created for ${jmeterScriptPath}/${jmeterScriptName}" -ForegroundColor Cyan
    if($props.driver -eq "virtualbox"){
        .\dockermachine\docker-machine.exe create --driver virtualbox ${controllerHost}
    }elseif($props.driver -eq "hyperv"){
        .\dockermachine\docker-machine.exe create --driver hyperv --hyperv-virutal-switch $props.hypervswitchname ${controllerHost}
    }elseif($props.driver -eq "aws"){
        .\dockermachine\docker-machine.exe create --driver amazonec2 --amazonec2-access-key $props.accesskeyid --amazonec2-secret-key $props.accesskeypass  --amazonec2-region ap-southeast-2 $loadhostname
    }else{
        Write-Host "Driver type not specified or the driver type does not exists." -ForegroundColor Red
        Exit-PSHostProcess
    }
    
    $controllerip= .\dockermachine\docker-machine.exe ip $controllerHost
    .\dockermachine\docker-machine.exe env $controllerHost --shell powershell
}else{
    $controllerHost=$props.host
    Write-Host "Controller ${controllerHost} is being setup for ${jmeterScriptPath}/${jmeterScriptName}" -ForegroundColor Cyan
    
    $isalive = .\dockermachine\docker-machine.exe status $controllerHost

    if($isalive -eq "Stopped" ){
        Write-Host "Controller ${controllerHost} is stopped. Starting Controller ..." -ForegroundColor Cyan
        .\dockermachine\docker-machine.exe start $controllerHost
    }elseif($isalive -eq "Running"){
        # do nothing
        Write-Host "Controller ${controllerHost} is already running" -ForegroundColor Gray
    }else{
        Write-Host "Creating Controller machine ${controllerHost}"
        if($props.driver -eq "virtualbox"){
            .\dockermachine\docker-machine.exe create --driver virtualbox ${controllerHost}
        }elseif($props.driver -eq "hyperv"){
            .\dockermachine\docker-machine.exe create --driver hyperv --hyperv-virutal-switch $props.hypervswitchname ${controllerHost}
        }elseif($props.driver -eq "aws"){
            .\dockermachine\docker-machine.exe create --driver amazonec2 --amazonec2-access-key $props.accesskeyid --amazonec2-secret-key $props.accesskeypass  --amazonec2-region ap-southeast-2 $loadhostname
        }else{
            Write-Host "Driver type not specified or the driver type does not exists." -ForegroundColor Red
            Exit-PSHostProcess
        }
    }
}

Write-Host "Copying Jmeter Setup on Controller" -ForegroundColor Cyan
.\dockermachine\docker-machine.exe ssh ${controllerHost} "cd ~;mkdir -p tmp;cd ~/tmp/; mkdir -p controller"

#Copy Jmeter Setup to Server
.".\PerfScripts\common\copyOnCloud.ps1" ${jmeterpath} $tmpfolder $controllerHost $isdocker

Write-Host "Copying Jmeter Script File on Controller" -ForegroundColor Cyan
#Copy Jmeter Script file to Server     
.".\PerfScripts\common\copyOnCloud.ps1" "${jmeterScriptPath}\${jmeterScriptName}" $tmpfolder $controllerHost $isdocker
.".\PerfScripts\common\copyOnCloud.ps1" "${jmeterScriptPath}\jmeterData.csv" $tmpfolder $controllerHost $isdocker
.".\PerfScripts\common\copyOnCloud.ps1" "${jmeterScriptPath}\jmeter.prop" $tmpfolder $controllerHost $isdocker
if($isdocker){
    #Copy Dockerfile to Server     
    Write-Host "Setting up Docker on Controller..." -fore Green
    .".\PerfScripts\common\copyOnCloud.ps1" ".\jmeter-docker\Dockerfile" $tmpfolder $controllerHost $isdocker
    .\dockermachine\docker-machine.exe ssh $controllerHost "cd /home/docker/tmp/controller/ ; docker build . --tag jmetercontroller-docker -q"
    
    Write-Host "Starting Jmeter docker on Controller ..." -fore Green
    $cmd ="docker run --network host --mount type=bind,source=/home/docker/tmp/controller/,target=/home jmetercontroller-docker:latest ./bin/jmeter -n -t /${jmeterScriptName} -l /home/outfile.jtl --globalproperty /jmeter.prop -R ${remoteLoadGen} -Jserver.rmi.ssl.disable=true -Djava.rmi.server.hostname=${controllerip} "
}else{
    #run jmeter bat on controller
    .\dockermachine\docker-machine.exe $controllerHost "tar -xzf ${tmpfolder}/jmeterSetup.tar.gz -C ${tmpfolder}"
    Write-Host "Starting Jmeter Script on Controller ..." -fore Cyan
    $cmd="chmod 700 -R ~/tmp/controller; ~/tmp/controller/apache-jmeter-5.1.1/bin/jmeter -n -t ${tmpfolder}/${jmeterScriptName} -l ./outfile.jtl --globalproperty ${tmpfolder}/jmeter.prop -R ${remoteLoadGen} -Djava.rmi.server.hostname=${controllerip} -Dserver.rmi.localport=60000 -Jserver.rmi.ssl.disable=true"
}
Write-Host "Start Jmeter Script execution on ${controllerHost}" -fore Green
.\dockermachine\docker-machine.exe ssh $controllerHost $cmd
Write-Host "Getting results file on local Report folder" -ForegroundColor Cyan
.".\PerfScripts\common\getFromCloud.ps1" ./Report ~/tmp/controller/outfile.jtl $controllerHost $isdocker