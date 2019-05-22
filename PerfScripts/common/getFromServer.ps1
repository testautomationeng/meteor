#Use WMIRC to login into the machine and copy files
$chost = $args[0]
$ostype = $args[1]
$filename = $args[2]
$filePath = $args[3]
$serverType = $args[4]
$ppk = $args[5]
$username = $args[6]

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
    .\lib\pscp.exe -r -batch -q -i ".\keyfile\${ppk}" -scp "${username}@${chost}:~${destPath}${filename}" "${filePath}${filename}"
}else{
    Write-Host "controller OS is not defined " -ForegroundColor Red
    Exit-PSHostProcess
}