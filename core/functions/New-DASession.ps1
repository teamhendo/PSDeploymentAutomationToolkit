function New-DASession {
[CmdletBinding()]
param (
     [Parameter(Mandatory=$false, 
     ValueFromPipeline=$true)]
     [ValidateNotNullOrEmpty()]
     [System.Management.Automation.PSCredential]$CredentialObject,
     [Parameter(Mandatory=$true, 
     ValueFromPipeline=$true)]
     [ValidateNotNullOrEmpty()]
     $ScriptDirectory,
     [Parameter(Mandatory=$false, 
     ValueFromPipeline=$true)]
     [ValidateNotNullOrEmpty()]
     [uri]$URI
)

Begin {
     Write-Log -Component "New-DASession" `
               -Type 1 `
               -LogFile $scriptLogFile `
               -Message 'Attempting to establish API session.'
}

Process {
     if ([bool]$(Get-TaniumSavedWebSession -ErrorAction SilentlyContinue))
     {
          Write-Log -Component "New-DASession" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message 'Preexisting session detected.'
          
          $sessionObject = Get-TaniumSavedWebSession
     }

     if (!($sessionObject))
     {
          try {
               if (!($URI)) 
               {
                    Write-Log -Component "New-DASession" `
                              -Type 1 `
                              -LogFile $scriptLogFile `
                              -Message 'Gathering Tanium URI input from user:'
                    
                    $URI = Get-DAAddress
               }
               
               if (!($CredentialObject)) 
               {
                    do 
                    {
                         $CredentialObject = Get-DACredentials -URI $URI
                    } 
                    until ($CredentialObject)
               }
     
               $sessionObject = New-TaniumWebSession -Credential $credentialObject -ServerURI $URI.OriginalString -ErrorAction Stop
     
               if ([bool]$(Get-TaniumSavedWebSession -ErrorAction SilentlyContinue) -eq $true) {
               
                    Write-Log -Component "New-DASession" `
                         -Type 1 `
                         -LogFile $scriptLogFile `
                         -Message 'Tanium API session created'
               }
          }
          catch [System.Net.WebException],[System.Exception]
          {
               Write-Log -Component "New-DASession" `
                         -Type 2 `
                         -LogFile $scriptLogFile `
                         -Message 'Tanium API session could not be created with certificate validation.  Attempting with -DisableCertificateValidation flag.'
               
               $sessionObject = New-TaniumWebSession -Credential $credentialObject -ServerURI $URI.OriginalString -DisableCertificateValidation -ErrorAction Stop
     
               if ([bool]$(Get-TaniumSavedWebSession -ErrorAction SilentlyContinue) -eq $true) {
                    Write-Log -Component "New-DASession" `
                              -Type 2 `
                              -LogFile $scriptLogFile `
                              -Message 'Tanium API session created with -DisableCertificateValidation flag.' 
               }

               if (!($sessionObject))
               {
                    $errorMessage = $Error[0].Exception.Message
                    $errorType = $Error[0].Exception.GetType().FullName
          
                    Write-Log -Component "New-DASession" `
                              -Type 3 `
                              -LogFile $scriptLogFile `
                              -Message $(-join ('Tanium API session could not be created: ',$errorMessage,' Type: ',$errorType))

                    exit
               }
          }
     }
}

End {
     Remove-Variable credentialObject

     if ($sessionObject) 
     {
          return $sessionObject
     }
     else 
     {
          $errorMessage = $Error[0].Exception.Message
          $errorType = $Error[0].Exception.GetType().FullName

          Write-Log -Component "New-DASession" `
                    -Type 3 `
                    -LogFile $scriptLogFile `
                    -Message $(-join ("An API session could not be created with $($URI.OriginalString): ",$errorMessage,' Type: ',$errorType))
     }
}
}