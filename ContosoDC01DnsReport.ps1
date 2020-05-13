# Note:
# Start-Process line has file paths hard coded. A later revision of this script may change this to use variables.
# Touch empty ContosoDC01DnsReport.csv file, PS script looks at timestamp on this file and fails if it doesn't exist.
 
$dnsLogSize = 50MB
$reportHours = 12
 
$dnsLogPath = "\\ContosoDC01.contoso.com\DNSLogs$\ContosoDC01Dns.log"
$reportPath = "C:\DNSLogReports\ContosoDC01DnsReport.csv"
$reportPathHtml = "C:\DNSLogReports\ContosoDC01DnsReport.html"
 
$lastWrite = (get-item $reportPath).LastWriteTime
$timespan = new-timespan -hours $reportHours
 
if (((get-date) - $lastWrite) -gt $timespan) {
     
    # Older
    Write-Host "Older than $reportHours hours"
     
    if((Get-Item $dnsLogPath).length -gt $dnsLogSize) {
         
        Write-Host "File larger than $dnsLogSize generating updated report"
        # File paths hard coded in next line.
        Start-Process -FilePath "C:\Program Files (x86)\Log Parser 2.2\LogParser.exe" -Wait -ArgumentList "-i:TSV -o:CSV -nskiplines:30 -headerRow:off -iSeparator:space -nSep:1 -fixedSep:off `"SELECT field9 AS IP, REVERSEDNS(IP) AS Name, count(IP) as QueryCount INTO C:\DNSLogReports\ContosoDC01DnsReport.csv FROM \\ContosoDC01.contoso.com\DNSLogs$\ContosoDC018Dns.log WHERE field11 = 'Q' GROUP BY IP ORDER BY QueryCount DESC`""
 
        Write-Host "Generating HTML version"
        Start-Sleep -s 5
        Import-CSV $reportPath | ConvertTo-Html | Out-File $reportPathHtml
     
    } else {
        # File smaller do nothing
        }
 
} else {
    # Newer do nothing
    }
