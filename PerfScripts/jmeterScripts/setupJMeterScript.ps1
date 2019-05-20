$tCount = $args[0]
$rPeriod = $args[1]
$lCount = $args[2]
$duration = $args[3]
$delay = $args[4]
$gServer=$args[5]
$gPort=$args[6]
#open jmeter.prop file and update values of properies

Import-Csv -Path "./PerfScripts/jmeterScripts/jmeterData.csv" | ForEach-Object {
    foreach ($item in $_.PSObject.Properties) {
        $csvList = ${csvList} +"$($item.Name)=$($item.Value)`r`n " 
    }
}
$len = $csvList.length
$csvList = $csvList.substring(0,$len-2)
#Write-Host $csvList
Set-Content -Path "./PerfScripts/jmeterScripts/jmeter.prop" -Value "threads=${tCount} 
rampUpPeriod=${rPeriod}
loopCount=${lCount}
schDuration=${duration}
schDelay=${delay}
gServer=${gServer}
gPort=${gPort}
${csvList}"
