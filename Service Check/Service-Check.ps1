# ====== Email Settings ======
$sendEmail = $true
$sendTo = "me@domain.com"
$sendFrom = "noreply@domain.com"
$smtpServer = "smtp.domain.com"
$subject = "INFO: $(hostname) - Service was stopped"

# Initialize array
$restartedServices = @()


# ============================== #
# ======== Main Logic ========== #
# ============================== #

# Get all services that start with "MYNAME"
$GetService = Get-Service | Where-Object { $_.DisplayName -like "MYNAME*" }

foreach ($Service in $GetService) {
    Write-Host ("{0,-30} | {1,-10} | {2}" -f $Service.DisplayName, $Service.Status, $Service.StartType)

    # Restart any Automatic service that is Stopped
    if ($Service.StartType -eq 'Automatic' -and $Service.Status -eq 'Stopped') {
        try {
            Start-Service -Name $Service.Name -ErrorAction Stop
            Write-Host "$($Service.DisplayName) has been restarted." -ForegroundColor Yellow
            # make a note of the restarted service
            $restartedServices += $Service.DisplayName
        }
        catch {
            Write-Warning "Failed to restart $($Service.DisplayName): $_"
        }
    }
}

# ============================== #
# ======== Send Email ========== #
# ============================== #

if ($sendEmail -and $restartedServices.Count -gt 0) {
    $body  = "The following services were found stopped and have been restarted on $(hostname):`n`n"
    foreach ($serviceName in $restartedServices) {
        $body += " - $serviceName`n"
    }

    Send-MailMessage -To $sendTo `
                     -From $sendFrom `
                     -Subject $subject `
                     -Body $body `
                     -SmtpServer $smtpServer

    Write-Host "Email notification sent to $sendTo" -ForegroundColor Green
}
else {
    Write-Host "No stopped MHS services found, or no email configured." -ForegroundColor Cyan
}

