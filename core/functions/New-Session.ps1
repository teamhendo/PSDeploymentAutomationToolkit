function New-Session {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$CredentialObject,
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        $Reference,
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        $ScriptDirectory
        
    )
    
    Begin {
        Write-Log   -Component "New-Session" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message 'Attempting to establish API connection...'
    }

    Process {
        try {
            $sessionObject = New-TaniumWebSession -credential $credentialObject -ServerURI $reference.taniumServer -ErrorAction Stop
                            
            if ([bool]$(Get-TaniumSavedWebSession -ErrorAction SilentlyContinue) -eq $true) {
                Write-Log   -Component "New-Session" `
                            -Type 1 `
                            -LogFile $scriptLogFile `
                            -Message 'Tanium API session created'
            }
        }
        catch [System.Net.WebException]
        {
            if ($error[0].Exception.Message -like "*Could not establish trust relationship for the SSL/TLS secure channel*")
            {
                Write-Log   -Component "New-Session" `
                            -Type 2 `
                            -LogFile $scriptLogFile `
                            -Message 'Tanium API session could not be created with certificate validation.  Attempting with -DisableCertificateValidation flag.'

                $sessionObject = New-TaniumWebSession -credential $credentialObject -ServerURI $reference.taniumServer -DisableCertificateValidation -ErrorAction Stop

                if ([bool]$(Get-TaniumSavedWebSession -ErrorAction SilentlyContinue) -eq $true) {
                    Write-Log   -Component "New-Session" `
                                -Type 2 `
                                -LogFile $scriptLogFile `
                                -Message 'Tanium API session created with -DisableCertificateValidation flag.' 
                }
            }
        }
        catch 
        {
            $errorMessage = $error[0].Exception.Message
            
            Write-Log   -Component "New-Session" `
                        -Type 3 `
                        -LogFile $scriptLogFile `
                        -Message "(-join ('Tanium API could not be created: ',"$errorMessage"))" 
            
            exit
        }
    }

    End {
        Remove-Variable credentialObject
        
        return $sessionObject
    }
    
}