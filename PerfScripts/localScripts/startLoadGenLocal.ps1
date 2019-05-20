$props = $args[0]
$isDocker = $args[1]
$jmeterPath = $args[2]
$jmeterScriptPath = $args[3]
$jmeterScriptName = $args[4]
$loadhostList=$props.loadgen.host

$loadhostArr = $loadhostList.Split(",")
for ($i = 0; $i -lt $loadhostArr.Count; $i++) {
    $loadhost = $loadhostArr[$i]
    
    Write-Host "Load Generator ${loadhost} is being setup..." -ForegroundColor Cyan
    .".\PerfScripts\common\runCommandOnServer.ps1" $loadhost $props.loadgen.OS "cd ~; mkdir -p tmp; cd ~/tmp/; mkdir -p loadgen" $props.loadgen.privatekey
    #Copy Jmeter Setup to Server
    Write-Host "Copying JMeter setup on load generator ${loadhost}"
    .".\PerfScripts\common\copyOnServer.ps1" $loadhost $props.loadgen.OS $jmeterPath "loadgen" $props.loadgen.privatekey 
    .".\PerfScripts\common\copyOnServer.ps1" $loadhost $props.loadgen.os "${jmeterScriptPath}\${jmeterScriptName}" "loadgen" $props.loadgen.privatekey
    .".\PerfScripts\common\copyOnServer.ps1" $loadhost $props.loadgen.OS "${jmeterScriptPath}\jmeterData.csv" "loadgen" $props.loadgen.privatekey
    .".\PerfScripts\common\copyOnServer.ps1" $loadhost $props.loadgen.OS "${jmeterScriptPath}\jmeter.prop" "loadgen" $props.loadgen.privatekey
    if($isDocker){
        Write-Host "Copying Dockerfile on Loadgen " $loadhost -ForegroundColor Green
        .".\PerfScripts\common\copyOnServer.ps1" $loadhost $props.loadgen.OS ".\jmeter-docker\Dockerfile" "loadgen" $props.loadgen.privatekey
        Write-Host "Setup Docker for loadgen" -fore Green
        ."./PerfScripts/common/setupDocker.ps1 " $props.loadgen.os $loadhost "server" $props.loadgen.privatekey
    }else{
        .".\PerfScripts\common\runCommandOnServer.ps1" $loadhost $props.loadgen.OS "tar -xzf ~/tmp/loadgen/jmeterSetup.tar.gz -C ~/tmp/loadgen" $props.loadgen.privatekey   
    }
    #run jmeter-server on load generator
    .".\PerfScripts\jmeterScripts\startJmeterLoadGen.ps1" $props.loadgen.OS $loadhost $isDocker $props.loadgen.privatekey

}