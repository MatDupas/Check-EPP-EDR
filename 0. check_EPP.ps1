
# GOAL: 
# -----
# The script checks services running in background and tries to identify well-known EPP/EDR 
# Author: Mathieu Dupas


$OutputFile = "AV-Enum-results.txt"
Start-Transcript -Path $OutputFile

# List of 110 EPP/EDR from https://www.aon.com/cyber-solutions/aon_cyber_labs/yours-truly-signed-av-driver-weaponizing-an-antivirus-driver/
$av = @('agentsvc.exe', 'mfemms.exe', 'SophosSafestore64.exe', 'alsvc.exe', 'msmpeng.exe', 'sophosui.exe', 'avastsvc.exe', 'notifier.exe', 'ssdvagent.exe', 'avastui.exe', 'ntrtscan.exe', 'sspservice.exe', 'avp.exe', 'paui.exe', 'svcgenerichost.exe', 'avpsus.exe', 'pccntmon.exe', 'swc_service.exe', 'bcc.exe', 'psanhost.exe', 'swi_fc.exe', 'bccavsvc.exe', 'psuamain.exe', 'swi_service.exe', 'ccsvchst.exe', 'psuaservice.exe', 'tesvc.exe', 'clientmanager.exe', 'remediationservice.exe', 'TmCCSF.exe', 'coreframeworkhost.exe', 'repmgr.exe', 'tmcpmadapter.exe', 'coreserviceshell.exe', 'RepUtils.exe', 'tmlisten.exe', 'cpda.exe', 'repux.exe', 'updaterui.exe', 'cptraylogic.exe', 'savadminservice.exe', 'vapm.exe', 'cptrayui.exe', 'savapi.exe', 'VipreNis.exe', 'cylancesvc.exe', 'savservice.exe', 'vstskmgr.exe', 'ds_monitor.exe', 'SBAMSvc.exe', 'wrsa.exe', 'dsa.exe', 'sbamtray.exe', 'sophossafestore.exe', 'efrservice.exe', 'sbpimsvc.exe', 'sophoslivequeyservice.exe', 'epam_svc.exe', 'scanhost.exe', 'sophososquery.exe', 'epwd.exe', 'sdcservice.exe', 'sophosfimservice.exe', 'hmpalert.exe', 'SEDService.exe', 'sophosmtrextension.exe', 'hostedagent.exe', 'sentinelagent.exe', 'sophoscleanup.exe', 'idafserverhostservice.exe', 'SentinelAgentWorker.exe', 'sophos ui.exe', 'iptray.exe', 'sentinelhelperservice.exe', 'cloudendpointservice.exe', 'klnagent.exe', 'sentinelservicehost.exe', 'cetasvc.exe', 'logwriter.exe', 'sentinelstaticenginescanner.exe', 'endointbasecamp.exe', 'macmnsvc.exe', 'SentinelUI.exe', 'wscommunicator.exe', 'macompatsvc.exe', 'sepagent.exe', 'dsa-connect.exe', 'masvc.exe', 'sepWscSvc64.exe', 'responseservice.exe', 'mbamservice.exe', 'sfc.exe', 'epab_svc.exe', 'mbcloudea.exe', 'smcgui.exe', 'fsagentservice.exe', 'mcsagent.exe', 'SophosCleanM64.exe', 'endpoint agent tray.exe', 'mcsclient.exe', 'sophosfilescanner.exe', 'easervicemonitor.exe', 'mctray.exe', 'sophosfs.exe', 'aswtoolssvc.exe', 'mfeann.exe', 'SophosHealth.exe', 'avwrapper.exe', 'mfemactl.exe', 'SophosNtpService.exe'
)


$bin_list = (Get-WmiObject win32_service | Where {$_.state -eq "Running"}).pathname | Where {$_ -notlike $null} | 
Foreach {($_.tostring().split("\")[-1]).trim('"',' ').tolower() } | ? {$_ -notlike "svchost*"}  

Write-Host "[+] List of binaries running in background :" -Fore Cyan
echo $bin_list

foreach ($bin in $av) {
    foreach ($p in $bin_list) {
        if ($p.contains($bin))
            {
        Write-Host "[!] Found AV/EDR binary running : $bin" -Fore Cyan

        $full_path = (Get-WmiObject win32_service | Where {$_.state -eq "Running"}).pathname | 
        Where {$_ -notlike $null} | Foreach {$_.tostring().tolower()} | where {$_ -like "*{0}*" -f $bin}  

        Write-Host "[!] Path of AV/EDR : $full_path" -Fore Cyan 
            }

    }
}


Write-Host "[+] General AV configuration :" -fore Cyan
Get-MpComputerStatus
Get-MpPreference

Write-host "[+] Filtering Get-MpPreference Properties set to True :" -Fore Cyan

$object = Get-MpPreference
foreach ($x in $object | get-member) {
    if ($x.MemberType -eq “Property”) 
        {if ($object.$($x.name) -eq "True") 
            { write-host $x.Name }
        }
    }

Write-Host "[+] Done. Results saved under $OutputFile." 
Stop-Transcript
