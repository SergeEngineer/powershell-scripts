#NAME: service_Check.ps1 
#AUTHOR: Serge Voloshenko
#DATE: 3/17/2022

# Create an array of all services running
$GetService = get-service


# Iterate throw each service on a host
foreach ($Service in $GetService)
{
    # Get all services starting with "MHS"
    if ($Service.DisplayName.StartsWith("MHS"))
    {
        # Show status of each service
        Write-Host ($Service.DisplayName, $Service.Status, $Service.StartType) -Separator "`t`t`t`t`t|`t"
        
        # Check if a service is service is RUNNING.  
        # Restart all "Automatic" services that currently stopped
		if ($Service.StartType -eq 'Automatic' -and $Service.status -eq 'Stopped' )
        {
            Restart-Service -Name $Service.DisplayName
            Write-Host $Service.DisplayName "|`thas been restarted!"   
		}
    }
}
