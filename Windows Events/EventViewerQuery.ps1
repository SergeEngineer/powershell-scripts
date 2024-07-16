

Get-WinEvent -LogName Application | Where-Object { $_.Message -like '*EQ20_*' }  | Out-GridView




Get-WinEvent -LogName Application -MaxEvents 20 | Format-List

