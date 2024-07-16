#Set Full control to one queue
Get-MsmqQueue -Name "testtrasactional" -QueueType Private | Set-MsmqQueueAcl -UserName "mhshouse\Serge.voloshenko" -Allow FullControl


#Get all Queues
$queue = Get-MsmqQueue -Name "*" -QueueType Private
Write-Host $queue -Separator "   " 


#Add user group "mhshouse\Application Administrators" with full permissions
Foreach-Object { Set-MsmqQueueAcl -InputObject $queue -UserName "mhshouse\Application Administrators" -Allow "FullControl"}


#Remove User from Securty Access
$rights = "FullControl", "DeleteQueue", "ReceiveMessage","PeekMessage", "ReceiveJournalMessage", "GetQueueProperties", "SetQueueProperties", "GetQueuePermissions", "SetQueuePermissions", `
          "TakeQueueOwnership", "WriteMessage"
$rights | Foreach-Object { Set-MsmqQueueAcl -InputObject $queue -UserName "ANONYMOUS LOGON" -Remove $PSItem}


#Re-Add "everyone" back with permission to "receive messages" only. User must be removed from the list
$rights = "ReceiveMessage", "ReceiveJournalMessage", "GetQueueProperties", "GetQueuePermissions"
$rights | Foreach-Object { Set-MsmqQueueAcl -InputObject $queue -UserName "Everyone" -Allow $PSItem}

#Set-MsmqQueueAcl -InputObject $queue -UserName "CONTOSO\DavidChew" -Deny TakeQueueOwnership
