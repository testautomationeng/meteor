#Use WMIRC to login into the machine and copy files
$chost = $args[0]
$ostype = $args[1]
$filePath = $args[2]
$serverType = $args[3]
$ppk = $args[4]
$destPath = "" 

if($ostype -eq "windows"){
    #TBD
}elseif($ostype -eq "linux"){
    if($serverType -eq "loadgen"){
        $destPath = "/tmp/loadgen/"
    }else{
        $destPath = "/tmp/controller/"
    }
    #Copy Jmeter Setup to Linux Server
    .\lib\pscp.exe -r -batch -q -i ".\keyfile\${ppk}" -scp $filePath "pranav@${chost}:~${destPath}"
}else{
    Write-Host "controller OS is not defined " -ForegroundColor Red
    Exit-PSHostProcess
}