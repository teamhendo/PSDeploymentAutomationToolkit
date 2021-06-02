function New-Session {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true,
        Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $scriptDirectory,
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true,
        Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $reference    
    )

    #Requires -Modules TanREST
    #Requires -Version 3.0

    try {
        $sessionObject = New-TaniumWebSession -credential $credentialObject -ServerURI $reference.taniumServer -ErrorAction Stop
                        
        if ([bool]$(Get-TaniumSavedWebSession -ErrorAction SilentlyContinue) -eq $true) {
            Write-Log -Message 'Tanium API session created' -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile
        }
    }
    catch [System.Net.WebException]
    {
        if ($error[0].Exception.Message -like "*Could not establish trust relationship for the SSL/TLS secure channel*")
        {
            Write-Log -Message 'Tanium API session could not be created with certificate validation.  Attempting with -DisableCertificateValidation flag.' -Component "Core Initialization" -Type 2 -LogFile $scriptLogFile
        }
        
    }
    catch 
    {
        $errorMessage = $error[0].Exception.Message
        
        Write-Log -Message "(-join ('Tanium API could not be created: ',"$errorMessage"))" -Component "Core Initialization" -Type 3 -LogFile $scriptLogFile
        
        exit
    }

    if ($null -eq $sessionObject)
    {
        $sessionObject = New-TaniumWebSession -credential $credentialObject -ServerURI $reference.taniumServer -DisableCertificateValidation -ErrorAction Stop

        if ([bool]$(Get-TaniumSavedWebSession -ErrorAction SilentlyContinue) -eq $true) {
            Write-Log -Message 'Tanium API session created with -DisableCertificateValidation flag.' -Component "Core Initialization" -Type 2 -LogFile $scriptLogFile
        }
    }
}