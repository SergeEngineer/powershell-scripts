#NAME: Start an AppPool if it failled and has State = stopped
#AUTHOR: Serge Voloshenko
#DATE: 11/27/2019

#Create list of required AppPools
$AppPools = "A2.TAP.MSCEIT"; #"a2.mhsassessments.com", "a2.TAP",

# Get every pool from the array
foreach ($AppPool in $AppPools)
{
    # if AppPool status is Stopped -> Start the AppPool
    $Status = Get-WebAppPoolState $AppPool
	if ($Status.Value -eq "Stopped")
	{
        #Write-Host ($Status.Value)
        Start-WebAppPool -Name $AppPool
        #Write-Host $AppPool " started"

        $body = "The applicatin pool $AppPool failed on 192.168.100.50 and it was restarted. `nCurrent status of the servicie is " + $Status.Value| Out-String

        Send-MailMessage -From "noreply@mhs.com" `
                         -Subject "** RECOVERY - $AppPool has been started" `
                         -To 'sv@mhs.com', 'n@MHS.com' `
                         -Body $body `
                         -SmtpServer mhsmail.mhs.com
	}
}
