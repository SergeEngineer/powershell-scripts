[void] [Reflection.Assembly]::LoadWithPartialName("System.Messaging")

$scriptPath = $MyInvocation.MyCommand.Path
$reader = [System.IO.File]::OpenText($scriptPath.Substring(0,$scriptPath.LastIndexOf("\")) + "\queuenames.txt")

while($null -ne ($queueName = $reader.ReadLine())) {

    if (![System.Messaging.MessageQueue]::Exists(".\private$\" + $queueName)){
        Write-Host "Creating queue with name: $queueName"
        $queue = [System.Messaging.MessageQueue]::Create(".\private$\" + $queueName, $true) 
        
        $queue.UseJournalQueue = $true

        $queue.SetPermissions("Everyone", 
                              [System.Messaging.MessageQueueAccessRights]::FullControl, 
                              [System.Messaging.AccessControlEntryType]::Set) 

        $queue.SetPermissions("ANONYMOUS LOGON", 
                              [System.Messaging.MessageQueueAccessRights]::FullControl, 
                              [System.Messaging.AccessControlEntryType]::Set)                               
    }
    else {
        Write-Host "Queue already exists." 
    }

}



#$queues = [System.Messaging.MessageQueue]::GetPrivateQueuesByMachine(".") 
#foreach ($q in $queues){
# Write-Host "        "$q.QueueName -ForegroundColor Yellow
#}
 
Write-Host "All the work be done, b'y!";