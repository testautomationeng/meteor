$localfolder=$args[0]
$remotefolder=$args[1]
$loadgenname=$args[2]
$isdocker=$args[3]

$loadgenip = .\dockermachine\docker-machine.exe ip $loadgenname
if($isdocker){
    $user = $env:UserName
    $idloc="c:\\users\\${user}\\.docker\\machine\\machines\\${loadgenname}\\id_rsa"
}else{
    $user = $env:UserName
    $idloc=".\keyfile\id_rsa"
}
.\lib\scp.exe -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=quiet -3 -r -o Port=22 -o IdentityFile=$idloc docker@${loadgenip}:${remotefolder} $localfolder