#NAME: Check_ErrorMessage_Queue.ps1 
#AUTHOR: Serge Voloshenko
#DATE: 09/14/2020

$MsgThreshold = 5

$QueueArray = "mhs.tap.csap.errors", "mhs.tap.csi.errors", "mhs.tap.dlp.errors", "mhs.tap.dsp.errors", "mhs.tap.ee.errors", "mhs.tap.dlp.errors", "mhs.tap.elp.errors", 
              "mhs.tap.eq360.errors", "mhs.tap.eq360.reports.errors", "mhs.tap.eqi.errors", "mhs.tap.eqi.reports.errors", "mhs.tap.hedu.errors", "mhs.tap.hrg.errors", "mhs.tap.isi.errors", "mhs.tap.msceit.errors", "mhs.tap.msceit.reports.errors", "mhs.tap.pearman.errors", "mhs.tap.portal.errors",
              "rocket.errors", "rsicore.errors", "cefiacore.errors", "pvaterror";

foreach ($queue in $QueueArray)
{
    # Create each MSMQ object
    [System.Reflection.Assembly]::LoadWithPartialName("System.Messaging") | Out-Null
    $MessageQueue = New-Object System.Messaging.MessageQueue (".\private$\" + $queue)
    
    # Get amount of the messages in the queue for the past hour
    $MessageQueue.MessageReadPropertyFilter.SetAll()
    $PastHour = (Get-Date).AddHours(-1)
    $countFailedMessages = 0
    $logs = @()

    foreach ($message in $MessageQueue )
    {
        if ($PastHour -lt $message.ArrivedTime)
        {
            #Write-Host $message.ArrivedTime
            $countFailedMessages++
            #Write-Host $countFailedMessages
            
            if ($countFailedMessages -lt 5)
            {
                $logs += "`n==============================================================================================================================================================="
                $logs += $message.ArrivedTime.ToString()
                $logs += "`n"
                $logs += $message.Label.ToString()
                $logs += "`n"
                $logs += (New-Object System.Text.UTF8Encoding).GetString($message.BodyStream.ToArray())
                $logs += "`n"
            }
        }
    }
    
    Write-Host $queue `t $countFailedMessages "failed messages for the past hour"
    

    # Send notification if amount of failed messages exeding the treshold
    If($countFailedMessages -gt $MsgThreshold)
    {
        
        $emailMessage = "$countFailedMessages messages failed for the past hour in the $queue queue.`nThe Message Queue exceeded critical threshold of $MsgThreshold failed messages per hour.`nServer: 869841-queue `nPlease find below the log for most recent messages:`n"
        foreach ($log in $logs)
        {
            #Write-Host $log `n
            $emailMessage += ($log + "`n")
        }

        #, nick.monaco@MHS.com, paul.stamou@MHS.com ` #, mhsalerts@blairtechnology.com, #"#TechSupport@MHS.com", "dyan.buerano@MHS.com"
        #-Cc "#Programmers@MHS.com" ` 
        Send-MailMessage -To serge.voloshenko@mhs.com, nick.monaco@MHS.com `
                         -Cc developmentsupport@mhs.com `
                         -From noreply@mhs.com `
                         -Subject "WARNING - $countFailedMessages failed msgs in $queue queue for the past hour" `
                         -Body $emailMessage `
                         -SmtpServer mhs-com.mail.protection.outlook.com       
    }
}
