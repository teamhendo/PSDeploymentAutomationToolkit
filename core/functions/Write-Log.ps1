function Write-Log {
  [CmdletBinding()]
  param (
  [Parameter(Mandatory=$true)]
  $LogFile,
  [Parameter(Mandatory=$false)]
  $MaxLogSize = [int]$(10240),
  [Parameter(Mandatory=$true, 
    ValueFromPipeline=$true)]
  [ValidateNotNull()]
  $Message,
  [Parameter(Mandatory=$true, 
    ValueFromPipeline=$true)]
  [ValidateNotNull()]
  $Component,
  [Parameter(Mandatory=$true, 
    ValueFromPipeline=$true)]
  [ValidateNotNull()]
  $Type
  )
  
switch ($Type)
{
    1 { $Type = "Info" }
    2 { $Type = "Warning" }
    3 { $Type = "Error" }
}

if ((Get-Item $logFile).Length/1KB -gt $MaxLogSize)
{
    $tempLog = $logFile
    Remove-Item ($tempLog.Replace(".log", ".lo_")) -ErrorAction SilentlyContinue
    Rename-Item $logFile ($tempLog.Replace(".log", ".lo_")) -Force
}

$log = "{0} `$$<{1}><{2} {3}><thread={4}>" -f ("[$Type]" + " :: " + $Message), ("[$Component]"), (Get-Date -Format "MM-dd-yyyy"), (Get-Date -Format "HH:mm:ss.ffffff"), $pid
$log | Out-File -Append -Encoding UTF8 -FilePath ("filesystem::{0}" -f $logFile)

Write-Host $Message

}