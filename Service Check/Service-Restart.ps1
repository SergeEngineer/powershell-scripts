#NAME: service_restart.ps1 
#AUTHOR: Serge Voloshenko
#DATE: 5/1/2021
#MODIFIED: 5/12/2021 by Mrinalini to restart the EQI Report Core

#Create an array of all services running
$GetService = get-service -ComputerName "PrdApp5"

#Create a subset of the previous array for services you want to monitor
$ServiceArray = "EQIREPORTSCORE", "EQ360CORE";

# Get every services on a host
foreach ($Service in $GetService)
{
    # Compare all services with your list(array) of services
	foreach ($srv in $ServiceArray)
	{
        # if array much serivice list form a host
		if ($Service.name -eq $srv)
		{
            Write-Host ($Service.name, $Service.Status) -Separator "`t|`t"

            Restart-Service -Name $srv
            Write-Host $srv " |`thas been restarted!"  

            # wait the service to restart before restarting the next service
            Start-Sleep -Seconds 15
		}
	}
}
