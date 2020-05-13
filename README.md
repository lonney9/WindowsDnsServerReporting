# Windows DNS Server Reporting

## Summary

Generate reports from Windows DNS servers showing client query statistics.

Uses Windows DNS server debug logging and Microsoft Log Parser 2.2.

DNS servers output log to local storage, log directory is shared read-only.

An intermediate host is used to run a PowerShell script via Task Scheduler that reads the log over the network, parses it and outputs a CSV and HTML report for easy viewing. This removes the need for DCs / DNS hosts to run a script and users to login to them to retrieve the report.

The script is configured to only parse the log if has been X number of hours (e.g. 12) since the last report was generated and if the log file is over X (e.g. 50mb) size. The Windows DNS server debug log is cleared and started fresh when max log size is reached (this is by design). This way we can schedule the script to run every few minutes, and capture a reasonable amount of data a couple times a day, if nether condition is met, the script does nothing.

## Configuration

Microsoft TechNet article provides the basics of DNS debug log and parsing the log with Microsoft Log Parser 2.2: https://blogs.technet.microsoft.com/secadv/2018/01/22/parsing-dns-server-log-to-track-active-clients/

### DNS Server Debug Log

Created a local folder C:\DNSLogs and shared it as a read-only hidden share. Folder permissions not edited.

DNS server properties > Debug Logging > enabled only these options:

Log packets for debugging

Packet direction: Incoming

Transport Protocol: UDP and TCP

Packet contents: Queries/Transfers

Packet type: Request

Log file path: C:\DNSLogs\ContosoDC01Dns.log

Log file max size (bytes): 100000000 (100mb)

### Microsoft Log Parser 2.2

Downloaded and installed Microsoft Log Parser 2.2 from https://www.microsoft.com/en-us/download/details.aspx?id=24659

### Service Account for Task Scheduler

Create a service account.

Edited Relevant GPO and adde the service account to Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies/User Rights Assignment > Log on as batch job

Give service account read/modify permission on C:\DNSLogReports

### Task Scheduler

Create and configure task to run StartDnsReport.bat every 5 minutes with service account.
