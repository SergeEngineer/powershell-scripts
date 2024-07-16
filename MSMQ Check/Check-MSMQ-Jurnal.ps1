#NAME: Check_Message_MSMQ_Jurnal.ps1 
#AUTHOR: Serge Voloshenko
#DATE: 08/12/2022


# Get-MsmqQueue -QueueType Private | Format-Table -Property QueueName, MessageCount, JournalMessageCount;

$MsgThreshold = 100000


# Get all queues and message count
$AllQueues = Get-MsmqQueue -QueueType Private | Select QueueName, MessageCount, JournalMessageCount;

foreach ($queue in $AllQueues)
{
    If($queue.JournalMessageCount -gt $MsgThreshold -or $queue.MessageCount -gt $MsgThreshold)
    {   
        # Display affected Queues
        Write-Host $queue.QueueName
        
        $Queue_Name = $queue.QueueName.Replace("private$\","")
        $Queue_MessageCount = $queue.MessageCount
        $Queue_JournalMessageCount = $queue.JournalMessageCount

        # Send Email
        $EmailBody = "The Journal Message Count exceeded critical threshold of $MsgThreshold messages.`r`nPlease remote into MHS-CORE1 VM in Azure and purge jurnal for $Queue_Name queue.`r`nMake sure to archive all messages before deleting them all`r`n"

        Send-MailMessage -To "sv@mhs.com", "p@MHS.com" `
                    -Cc "nm@MHS.com" `
                    -From "noreply@mhs.com" `
                    -Subject "WARNING - $Queue_Name journal purged is required" `
                    -Body $EmailBody `
                    -SmtpServer mhs.mhs.com
        
        Write-Host "Notified about $Queue_Name"
    }   
    
}
