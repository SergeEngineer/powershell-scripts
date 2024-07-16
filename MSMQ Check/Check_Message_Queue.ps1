#NAME: Check_Message_Queue.ps1 
#AUTHOR: Serge Voloshenko
#DATE: 6/21/2021

[System.Reflection.Assembly]::LoadWithPartialName("System.Messaging") | Out-Null


# Queue list with lower threshold alert
$QueueArray_low = "mhs.tap.hrg.main", "mhs.tap.isi.main", "mhs.tap.msceit.main", "mhs.tap.msceit.reports.main", "mhs.tap.pearman.main", "mhs.tap.portal.main",
                  "assess.asrs.main", "assess.c3.main", "assess.cbrs.main", "assess.cefi.main", "assess.cefia", "assess.rsicore.main", "assess.pdpvts.main", "pvatqueue", "iassess.main";

$MsgThreshold = 30
$MsgThreshold_low = 5

# Get all queues and message count
$AllQueues = Get-MsmqQueue | Select QueueName, MessageCount


foreach ($queue in $AllQueues)
{
    # Set current executing path for a file to save current state of the queue
    $queueName = $queue.QueueName.Replace("private$\","")
    $queueMessageCount = $queue.MessageCount
    $filePath = ".\Queue-Status-" + $queueName + ".txt"

    # Do not check error queues
    if ($queue.QueueName.Contains("error") -or $queue.QueueName.Contains("temp"))
    {
        Write-Host "Skipped:" $queueName
    }
    else
    {
        # alert on 30 msgs in the queue                 alert on 5 msgs in the queue
        If(($queue.MessageCount -gt $MsgThreshold) -or ($queue.MessageCount -gt $MsgThreshold_low -and $QueueArray_low -contains $queueName))
        {
            Send-MailMessage -To sv@mhs.com, n@MHS.com `
                             -Cc "dev@mhs.com", "Tech@MHS.com" `
                             -From "noreply@mhs.com" `
                             -Subject "** PROBLEM - $queueMessageCount msgs in $queueName queue" `
                             -Body "Current count of all messages in the $queueName queue is $queueMessageCount.`nThe Message Queue count exceeded critical threshold of $MsgThreshold or $MsgThreshold_low messages.`nAlert sent from PrdQue1" `
                             -SmtpServer mhs.outlook.com
            
            # Flag each queue as Exceeded critical threshold.
            if (Test-Path -Path $filePath)
            {
                Set-Content -Path $filePath -Value "Exceeded"
            }
            else
            {
                New-Item $filePath -type "file" -value "Exceeded"
            }
            Write-Host "Alert sent for" $queueName - $queue.MessageCount
        }
        else
        {
            # If Message Queue is back to normal -> send an email with a Recovery message
            if (Test-Path -Path $filePath)
            {
                if ((Get-Content -Path $filePath).Equals("Exceeded"))
                {
                    Set-Content -Path $filePath -Value "Normal"
                    Send-MailMessage -To sv@mhs.com, nm@MHS.com `
                                     -From "noreply@mhs.com" `
                                     -Cc "#Programmers@MHS.com", "#TechSupport@MHS.com" `
                                     -Subject "** RECOVERY - $queueMessageCount msgs in $queueName queue" `
                                     -Body "Current count of all messages in the $queueName queue is $queueMessageCount.`nThe Message queue count is below critical threshold of $MsgThreshold messages.`nAlert sent from PrdQue1" `
                                     -SmtpServer mhs.outlook.com
                    
                    Write-Host "Recov sent for" $queueName - $queue.MessageCount -ForegroundColor Green
                }
            }
        }
    }
}
    