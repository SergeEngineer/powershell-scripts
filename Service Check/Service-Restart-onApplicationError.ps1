# ==============================
# Configuration
# ==============================
$checkIntervalMinutes = 15        # Customize time window
$logName              = "Application"
$searchString         = "Application Error text to search in Windows Application logs for the past internal specified in minutes"
$sendEmail            = $true
$sendTo               = "admin@contoso.com"
$sendFrom             = "noreply@contoso.com"
$smtpServer           = "smtp.contoso.com"
$subject              = "ALERT: Application error detected on $(hostname)"

# ==============================
# Initialize
# ==============================
$restartedServices = @()
$lastRunTime = (Get-Date).AddMinutes(-$checkIntervalMinutes)
$GetService = Get-Service | Where-Object { $_.DisplayName -like "MyService*" }

# ==============================
# Query Application Log
# ==============================
$events = Get-EventLog -LogName $logName -EntryType Error -After $lastRunTime |
    Where-Object { $_.Message -like "*$searchString*" }

# ==============================
# Action if errors found
# ==============================
if ($events.Count -gt 0) {
    Write-Warning "Matching application error(s) found. Restarting My Services..."

    foreach ($Service in $GetService) {
        Write-Host ("{0,-40} | {1,-10} | {2}" -f $Service.DisplayName, $Service.Status, $Service.StartType)

        if ($Service.StartType -eq 'Automatic') {
            try {
                Restart-Service -Name $Service.Name -Force -ErrorAction Stop
                Write-Host "$($Service.DisplayName) has been restarted." -ForegroundColor Yellow
                $restartedServices += $Service.DisplayName
            }
            catch {
                Write-Warning "Failed to restart $($Service.DisplayName): $_"
            }
        }
    }

    # ==============================
    # Email Notification
    # ==============================
    if ($sendEmail) {
        $body  = "Application error(s) detected on $(hostname):`n"
        $body += "Search string: '$searchString'`n"
        $body += "Time window: Last $checkIntervalMinutes minutes`n`n"
        $body += "The following services were restarted:`n"
        $body += ($restartedServices | ForEach-Object { " - $_" }) -join "`n"
        $body += "`n`nError Details:`n"

        foreach ($event in $events) {
            $body += "`n------------------------------`n"
            $body += "Time: $($event.TimeGenerated)`n"
            $body += "Source: $($event.Source)`n"
            $body += "Message:`n$($event.Message)`n"
        }

        Send-MailMessage -To $sendTo `
                         -From $sendFrom `
                         -Subject $subject `
                         -Body $body `
                         -SmtpServer $smtpServer

        Write-Host "Email notification sent to $sendTo" -ForegroundColor Green
    }
}
else {
    Write-Host "No matching errors found since $lastRunTime"
}
