$jmeterScriptName =$args[0]
$isDocker=$args[1]
$remoteLoadGen=$args[2]
$controllerhost=$args[3]
$ppk=$args[4]
$cmd=''
#$jmeterpropfile = "./PerfScripts/jmeterScripts/jmeter.prop"
#$csvfile = "./PerfScripts/jmeterScripts/jmeterData.csv"

# copying prop file to controller
#Write-Host "Transferring prop file to controller"
#.".\PerfScripts\common\copyOnServer.ps1" $controllerhost $props.loadgen.OS $jmeterpropfile "controller"
#Write-Host "Transferring csv file to controller"
#.".\PerfScripts\common\copyOnServer.ps1" $controllerhost $props.loadgen.OS "${jmeterScriptPath}\ "controller"

if($isDocker){
    # call docker setup scripts
    $cmd ="docker run --network host jmetercontroller-docker:latest ./bin/jmeter -n -t /${jmeterScriptName} -l ./outfile.jtl --globalproperty /jmeter.prop -R ${remoteLoadGen} -Jserver.rmi.ssl.disable=true -Djava.rmi.server.hostname=${controllerHost}"
}else{
    $cmd="chmod 700 -R ./tmp/controller; ./tmp/controller/apache-jmeter-5.1.1/bin/jmeter -n -t ~/tmp/controller/${jmeterScriptName} -l ./outfile.jtl --globalproperty ~/tmp/controller/jmeter.prop -R ${remoteLoadGen} -Djava.rmi.server.hostname=${controllerhost} -Dserver.rmi.localport=60000 -Jserver.rmi.ssl.disable=true"
}

write-Host "Start Jmeter Script execution on ${controllerhost}" -fore Green
plink.exe -i ".\${ppk}" -batch -ssh "pranav@${controllerhost}" ${cmd}