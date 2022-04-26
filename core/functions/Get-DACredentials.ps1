function Get-DACredentials {
[CmdletBinding()]
param (
     [Parameter(Mandatory=$true, 
     ValueFromPipeline=$true)]
     [ValidateNotNullOrEmpty()]
     [uri]$URI
)
Begin 
{
     [System.Management.Automation.PSCredential]$CredentialObject = $null
}

Process
{
     Write-Log -Component "Get-DACredentials" `
               -Type 1 `
               -LogFile $scriptLogFile `
               -Message "Prompting user for credentials." 
     
     $CredentialObject = Get-Credential -Message "Please provide the username and password to log in to $($URI.OriginalString). Note: Your username should include a domain prefix here if you also must provide one to log in to the Tanium console. Credentials are not stored."
}

End
{
     Write-Log -Component "Get-DACredentials" `
               -Type 1 `
               -LogFile $scriptLogFile `
               -Message "The user name provided was: $($CredentialObject.UserName)" 
     
     return $CredentialObject
}
}