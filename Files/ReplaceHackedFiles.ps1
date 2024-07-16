
$TapDefault = 'C:\inetpub\DNN_TAP2\Default.aspx'
if (Get-ChildItem -Path $TapDefault | Select-String -pattern "escort")
{
    # Write-Host "Escort!!!!"
    Copy-Item -Path 'C:\!Scripts\ReplaceHackedFiles\Default.aspx' -Destination $TapDefault -Force

    Send-MailMessage -To "sv@mhs.com, n@MHS.com" `
                    -From "DNN_hack@mhs.com" `
                    -Subject "PROBLEM - File has been replaced - $TapDefault" `
                    -Body "File $TapDefault has been replaced!" `
                    -SmtpServer mail.mhs.com
}
else
{
    Write-Host "Clean!!!!"
}

