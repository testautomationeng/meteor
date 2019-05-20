#Start Jmeter server on load generator
$ostype=$args[0]
$hostName = $args[1]
$isDocker=$args[2]
$ppk=$args[3]
$command=""


if($ostype -eq "windows"){
    Write-Host "Run command to start load generator on windows pc"
}elseif($ostype -eq "linux"){
    Write-Host "Starting Jmeter Server on load generator ${hostName}" -fore Green
    .".\PerfScripts\common\runCommandOnServer.ps1" $hostname $ostype "chmod 700 -R ~/tmp/" $ppk
    if($isDocker){
        Write-Host "Starting Jmeter Server docker on load generator ${hostName}" -fore Green
        $command = "nohup docker run --network host jmeterserver-docker:latest ./bin/jmeter-server -Jserver.rmi.ssl.disable=true -Djava.rmi.server.hostname=${hostName} > /dev/null &"
    }else{
        $command = "nohup ~/tmp/loadgen/apache-jmeter-5.1.1/bin/jmeter-server -Jserver.rmi.ssl.disable=true -Djava.rmi.server.hostname=${hostName} -Dserver.port=1099 -Dserver.rmi.localport=50000 > /dev/null &"
    }
    Write-Host $command
    .".\PerfScripts\common\runCommandOnServer.ps1" $hostname $ostype $command $ppk
}else{
    Write-Host "OS Type not defined for load generators" -fore Red
}
