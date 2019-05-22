$props = $args[0]
$location = $props.loadgen.location


if ($location -match "local"){
    $loadhostList=$props.loadgen.host
    $loadhostArr = $loadhostList.Split(",")
    for ($i = 0; $i -lt $loadhostArr.Count; $i++) {
        $loadhost = $loadhostArr[$i]        
        if($props.loadgen.location -eq "local-docker"){
            Write-Host "Cleaning Docker on Loadgen " $loadhost -ForegroundColor Cyan
            .".\PerfScripts\common\runCommandOnServer.ps1" $loadhost $props.loadgen.OS "docker stop `$(docker ps | awk {'print `$1'})" $props.loadgen.privatekey
        }else{
            Write-Host "Cleaning up Load Generator ${loadhost} " -ForegroundColor Cyan
            .".\PerfScripts\common\runCommandOnServer.ps1" $loadhost $props.loadgen.OS "kill `$(ps aux | grep jmeter | awk '{print `$2}')" $props.loadgen.privatekey
        }
    }
}else{
    $counter=$props.loadgen.cloud.loadgencount
    Write-Host "${counter}here"
    for ($i = 0; $i -lt $counter; $i++) {
        $loadhost = "loadgen${i}"
        if($props.loadgen.location -eq "cloud-docker"){
            Write-Host "Cleaning Docker on Loadgen " $loadhost -ForegroundColor Cyan
            .\dockermachine\docker-machine.exe ssh $loadhost "docker stop `$(docker ps | awk {'print `$1'})"
            .\dockermachine\docker-machine.exe stop $loadhost
        }else{
            Write-Host "Cleaning up Load Generator ${loadhost} " -ForegroundColor Cyan
            .\dockermachine\docker-machine.exe ssh $loadhost "kill `$(ps aux | grep jmeter | awk '{print `$2}')"
            .\dockermachine\docker-machine.exe stop $loadhost
        }
    }
}

if ($props.controller.location -eq "local"){    
    Write-Host "Cleaning up controller " $props.controller.host -ForegroundColor Cyan
    .".\PerfScripts\common\runCommandOnServer.ps1" $props.controller.host $props.controller.OS "kill `$(ps aux | grep jmeter | awk '{print `$2}')" $props.controller.privatekey
}elseif($props.controller.location -eq "local-docker") {
    Write-Host "Cleaning up controller " $props.controller.host -ForegroundColor Cyan
    .".\PerfScripts\common\runCommandOnServer.ps1" $props.controller.host $props.controller.OS "docker stop `$(docker ps | awk {'print `$1'})" $props.controller.privatekey
}elseif($props.controller.location -eq "cloud"){
    Write-Host "Cleaning up controller " $props.controller.cloud.host -ForegroundColor Cyan
    .\dockermachine\docker-machine.exe ssh $props.controller.cloud.host "kill `$(ps aux | grep jmeter | awk '{print `$2}')"
    .\dockermachine\docker-machine.exe stop $props.controller.cloud.host
}elseif($props.controller.location -eq "cloud-docker"){
    Write-Host "Cleaning up controller " $props.controller.cloud.host -ForegroundColor Cyan
    .\dockermachine\docker-machine.exe ssh $props.controller.cloud.host "docker stop `$(docker ps | awk {'print `$1'})"
    .\dockermachine\docker-machine.exe stop $props.controller.cloud.host
}
Write-Host "Completed clean up " -ForegroundColor Cyan