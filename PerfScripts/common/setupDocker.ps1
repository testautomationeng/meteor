$ostype=$args[0]
$hostname=$args[1]
$isServer=$args[2]

if($ostype -eq "windows"){
    $command = "cd c:/tmp/apache/; docker build . --tag jmeterserver-docker -q"
}elseif($ostype -eq "linux"){
    if($isServer -eq "server"){
        $command = "cd ~/tmp/loadgen/; docker build . --tag jmeterserver-docker -q"
    }else{
        $command = "cd ~/tmp/controller/; docker build . --tag jmetercontroller-docker -q"
    }
    
}else{
    Write-Host "OS type is not defined " -fore Red
}
.\lib\plink.exe -i .\privatekey.ppk -batch -ssh "pranav@${hostName}" ${command}