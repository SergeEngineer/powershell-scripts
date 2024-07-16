#NAME: Conners4_FailureCheck.ps1 
#AUTHOR: Serge Voloshenko
#DATE: 11/08/2022

# Contact list
$SendMailTO = 'sv@mhs.com', 'n@mhs.com'
$SendMailCC = 'IT_MHS.com', 'dev@mhs.com'

# SQL connection string
$sqlServer = '869683-SQLCLUS1'
$dbName = 'MHS_Common'
$table = 'MAP_RM_Jobs'
$sqlQuery = 'SELECT count(*) FROM [MHS_Common].[dbo].[MAP_RM_Jobs] '
$user = 'user'
$password = 'pass'

# Get the current UTC time as a [datetime] instance.
$CurrentTime1 = [DateTime]::UtcNow 
$15minBeforeNOW1 = $CurrentTime1.AddMinutes(-15)

# Convert to "yyyy-MM-dd HH:mm:ss" format
$CurrentTime2 = Get-Date $CurrentTime1 -Format "yyyy-MM-dd HH:mm:ss"
$15minBeforeNOW2 = Get-Date $15minBeforeNOW1 -Format "yyyy-MM-dd HH:mm:ss"

# Append to the sql query where clause
$where = "where Status = 4 and UpdatedDate between '" + $15minBeforeNOW2 +"' and '" + $CurrentTime2 + "';"
$sqlQuery += $where 

# Display the variables
Write-Host 'Current time:    ' $CurrentTime2
Write-Host '15 min bore now: ' $15minBeforeNOW2
Write-Host $sqlQuery

function createSqlConnection($sqlServer, $sqlPort, $dbName, $user, $password) {
    $sqlConnection = New-Object System.Data.SqlClient.sqlConnection
    if ($sqlPort) { $sqlServer = "$sqlServer,$sqlPort" }
    if ($user -and $password) {
        $sqlConnection.ConnectionString = "Server=$sqlServer; Database=$dbName; User Id=$user; Password=$password"
    } else {
        $sqlConnection.ConnectionString = "Server=$sqlServer; Database=$dbName; Integrated Security=True"
    }

    return $sqlConnection
}

function getRowCount($sqlConnection, $sqlQuery) {
    $sqlQuery = $sqlQuery
    $sqlConnection.Open()
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand($sqlQuery, $sqlConnection)
    $row_count = [Int32] $SqlCmd.ExecuteScalar()
    $sqlConnection.Close()
    return $row_count
}


$dbConn = createSqlConnection $sqlServer $null $dbName $user $password
$failedC4reports = getRowCount $dbConn $sqlQuery

Write-Host "Failed Conners4 reports: " $failedC4reports



if ($failedC4reports -gt -1) {
    
    Send-MailMessage -To sv@Mhs.com `
                     -Cc sv@Mhs.com `
                     -From "noreply@mhs.com" `
                     -Subject "** PROBLEM - $failedC4reports Conners4 reports failed" `
                     -Body "$failedC4reports Conners4 reports failed for the past 15min`nExecuted query: $sqlQuery`nAlert sent from 869683-SQLCLUS1" `
                     -SmtpServer mhs.mhs.com

    Write-Host "Notification is sent"
}