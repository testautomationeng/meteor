$props=$args[0]
$isdocker=$args[1]
$jmeterpath=$args[2]
$jmeterScriptPath=$args[3]
#$jmeterScripName=$args[4]
$loadgenList=""
$tmpfolder = "~/tmp/loadgen/"

$counter=$props.loadgencount
#run a loop to start load gen  
for ($i = 0; $i -lt $counter; $i++) {
    $loadhostname="loadgen${i}"
    Write-Host "Starting load generator instance # " $loadhostname
    
    $isalive = .\dockermachine\docker-machine.exe status $loadhostname

    if($isalive -eq "Stopped" ){
        Write-Host "load generator ${loadhostname} is stopped. Starting load generator"
        .\dockermachine\docker-machine.exe start $loadhostname
    }elseif($isalive -eq "Running"){
        # do nothing
        Write-Host "Load generator ${loadhostname} is already running"
    }else{
        Write-Host "Creating load generator machine ${loadhostname}"
        if($props.driver -eq "hyperv"){
            .\dockermachine\docker-machine.exe create --driver hyperv --hyperv-virtual-switch $loadhostname
        }elseif($props.driver -eq "virtualbox"){
            .\dockermachine\docker-machine.exe create --driver virtualbox $loadhostname
        }elseif($props.driver -eq "aws"){
            .\dockermachine\docker-machine.exe create --driver amazonec2 --amazonec2-access-key $props.accesskeyid --amazonec2-secret-key $props.accesskeypass  --amazonec2-region ap-southeast-2 $loadhostname
        }else{
            Write-Host "Driver details not provided" -ForegroundColor Red
            Exit-PSSession
        }
    }

    $loadhost= .\dockermachine\docker-machine.exe ip $loadhostname
    $loadgenList="${loadgenList},${loadhost}"

    .\dockermachine\docker-machine.exe env $loadhostname --shell powershell
    Write-Host "Load Generator ${loadhost} is being setup..." -ForegroundColor Cyan
    .\dockermachine\docker-machine.exe ssh $loadhostname "cd ~; mkdir -p tmp; cd ~/tmp/; mkdir -p loadgen" 
    
    #Copy Jmeter Setup to Server
    Write-Host "Copying JMeter files on load generator ${loadhostname}" -ForegroundColor Green
    .".\PerfScripts\common\copyOnCloud.ps1" $jmeterpath $tmpfolder $loadhostname $isdocker
    .".\PerfScripts\common\copyOnCloud.ps1" ${jmeterScriptPath}"\"${jmeterScriptName} $tmpfolder $loadhostname $isdocker
    .".\PerfScripts\common\copyOnCloud.ps1" "${jmeterScriptPath}\jmeterData.csv" $tmpfolder $loadhostname $isdocker
    .".\PerfScripts\common\copyOnCloud.ps1" "${jmeterScriptPath}\jmeter.prop" $tmpfolder $loadhostname $isdocker

    if($isdocker){
        Write-Host "Copying Dockerfile on load generator " $loadhostname -ForegroundColor Green
        .".\PerfScripts\common\copyOnCloud.ps1" ".\jmeter-docker\Dockerfile" $tmpfolder $loadhostname $isdocker
        Write-Host "Setting up Docker for load generator " -fore Green
        .\dockermachine\docker-machine.exe ssh $loadhostname "cd /home/docker/tmp/loadgen/ ; docker build . --tag jmeterserver-docker -q"
        Write-Host "Starting Jmeter Server docker on load generator ${loadhostname}" -fore Green
        $command = "nohup docker run --network host jmeterserver-docker:latest ./bin/jmeter-server -Jserver.rmi.ssl.disable=true -Djava.rmi.server.hostname=${loadhost} > /dev/null &"
    }else{
        .\dockermachine\docker-machine.exe ssh $loadhostname "tar -xzf ${tmpfolder}jmeterSetup.tar.gz -C ${tmpfolder}"
        Write-Host "Starting Jmeter Server on load generator ${loadhostname}" -ForegroundColor Cyan
        $command = "nohup ${tmpfolder}apache-jmeter-5.1.1/bin/jmeter-server -Jserver.rmi.ssl.disable=true -Djava.rmi.server.hostname=${loadhost} -Dserver.port=1099 -Dserver.rmi.localport=50000 > /dev/null &"
    }
    #run jmeter-server on load generator
    .\dockermachine\docker-machine.exe ssh $loadhostname "chmod 700 -R ~/tmp/;${command}"
}

#write loadgen server ips in a file
Write-Host "Writing load generator ip to loadgenlist.txt " -ForegroundColor Cyan
Write-Output $loadgenList | Out-File -FilePath ".\PerfScripts\cloudScripts\loadgenlist.txt"