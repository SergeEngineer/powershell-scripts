# smtp.office365.com `
Send-MailMessage -To sv@mhs.com `
                         -From "sv@mhs.com" `
                         -Subject "** PROBLqueue" `
                         -Body "Current count of all messageServer: 869841-queue" `
                         -SmtpServer smtp.office365.com `
                         -Port 587 `
                         -Credential 'serge.voloshenko@mhs.com' `
                         -UseSsl


# mail.mhs.com
Send-MailMessage -To sv@hotmail.com `
                         -From "noreply@mhs.com" `
                         -Subject "mhsmail.mhs.com" `
                         -Body "Current count of all messageServer: 869841-queue" `
                         -SmtpServer mhsmail.mhs.com
