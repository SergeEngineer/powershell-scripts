$Files = Get-ChildItem -Path C:\inetpub -Include ("*.aspx", "*.html", "*.sav", "*.ascx") -Recurse | `
Select-String -pattern ("Escort", "Hacked") | group path | select -ExpandProperty  name -Verbose


$body = $Files -join "`r`n" | Out-String

if ($Files -ne $null)
{
    Send-MailMessage -To "serge.voloshenko@mhs.com, nick.monaco@MHS.com, paul.stamou@MHS.com" `
                -cc "#Programmers@MHS.com"
                -From "DNN_hack@mhs.com" `
                -Subject "Files have been hacked" `
                -Body $body `
                -SmtpServer mail.mhs.com
}

