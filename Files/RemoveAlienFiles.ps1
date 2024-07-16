#List of Files
$OriginalASPXfiles = "dnnskins.aspx", "Default.aspx", "Upgrade.aspx", "Activation.aspx", "Resource_Settings.aspx", `
			 "Resource_Validation.aspx", "Resource_Skins.aspx", "Resource_Error.aspx", "Resource_Options.aspx", "Resource_Copy.aspx",`			
                     "Resource_Module.aspx", "Browser.aspx", "Options.aspx", "ErrorPage.aspx", "install.aspx", `
                     "InstallWizard.aspx", "KeepAlive.aspx", "paypalipn.aspx", "paypalsubscription.aspx", "subhost.aspx", `
                     "UpgradeWizard.aspx";  

#Get list of all .aspx files in a directory AND EXCLUDE Original Files frome the list
$AllFiles = Get-ChildItem -Path C:\inetpub\DNN_TAP2 -Include "*.aspx" -Exclude $OriginalASPXfiles -Recurse 


if ($AllFiles -ne $null)
{
    #Dispay FullPath to the file
    Write-Host $AllFiles.FullName -Separator "`n"

    #Remve the File
    Remove-Item $AllFiles.FullName #-WhatIf

    $body = $AllFiles.FullName -join "`n" | Out-String

    Send-MailMessage -From "DNN_hack@mhs.com" `
                     -Subject "** PROBLEM - ASPX Files have been deleted!" `
                     -To 'serge.voloshenko@mhs.com', 'nick.monaco@MHS.com', 'paul.stamou@MHS.com', 'ivan.ho@MHS.com', 'mrinalini.ravichandran@MHS.com' `
                     -Body $body `
                     -SmtpServer mail.mhs.com
} 
