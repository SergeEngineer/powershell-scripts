$Computers = "PrdApp1", "PrdApp2", "PrdApp3", "PrdApp4", "PrdApp5", "505598-VM3", "505594-vm2", "869843-core1", "1046797-SO", "PrdQue1", "869841-queue", "PrdDB1", "869683-SQLCLUS1", "869681-DB2Active", "869682-DB2Passive", "RS-DC01", `
             "DevApp1", "DevApp2", "DevDB1", "BtaApp1", "BtaApp2", "843484-vm8", "505601-vm5", "869751-DB3", "506497-app3", "506494-app2", "869753-DB4";

foreach ($Computer in $Computers) 
{
    Get-WMIObject Win32_NetworkAdapterConfiguration -Computername $Computer | `
        Where-Object {$_.IPEnabled -match "True"} | `
        Select-Object -property DNSHostName,ServiceName,@{N="DNSServerSearchOrder";
                    E={"$($_.DNSServerSearchOrder)"}},
                    @{N='IPAddress';E={$_.IPAddress}},
                    @{N='DefaultIPGateway';E={$_.DefaultIPGateway}} | FT  |
                    Export-Csv -Path c:\dns.csv -Force -Append -NoTypeInformation
}