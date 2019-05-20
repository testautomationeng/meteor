$hostname = $args[0]
$servertype = $args[1]
$command = $args[2]
$ppk=$args[3]

if($servertype -eq "windows"){
    #TBD
}else{
    .\lib\plink.exe -i ".\keyfile\${ppk}" -batch -ssh "pranav@${hostname}" $command
}