function Get-DeploymentEnvironmentConfiguration {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true, 
		ValueFromPipeline=$true,
		Position=0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		$ScriptDirectory,
		[Parameter(Mandatory=$true, 
		ValueFromPipeline=$true,
		Position=1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		$Reference    
	)

	#Requires -Version 3.0

	try 
	{
		
		Write-Log -Message "Attempting to automatically construct credentials sourced from $scriptDirectory/$($reference.taniumCredPath)" -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile
		
		Write-Output "Attempting to automatically construct credentials sourced from $scriptDirectory/$($reference.taniumCredPath)."

		$password = Get-Content -Path "$scriptDirectory/$($reference.taniumCredPath)" -ErrorAction Stop | ConvertTo-SecureString -ErrorAction Stop
		
		$credentialObject = New-Object System.Management.Automation.PSCredential -ArgumentList $($reference.taniumUser),$password
		
	}
	catch [System.Management.Automation.ItemNotFoundException]
	{
		
		Write-Log -Message "Automatic credential constructor failed because $($reference.taniumCredPath) not found." -Component "Core Initialization" -Type 3 -LogFile $scriptLogFile

		Write-Output "Automatic credential constructor failed because $($reference.taniumCredPath) not found."
		
	}
	catch [System.Security.Cryptography.CryptographicException]
	{
		
		Write-Log -Message "Automatic credential constructor failed.  $($Error[0].Exception)" -Component "Core Initialization" -Type 2 -LogFile $scriptLogFile

		Write-Output "Automatic credential constructor failed.  $($Error[0].Exception)"
		
	}

	if ($null -eq $password)
	{
		Write-Log -Message "Prompting user for manual credential input." -Component "Core Initialization" -Type 2 -LogFile $scriptLogFile

		Write-Output "Prompting user for manual credential input."
		
		try 
		{
			$password = Get-Credential -Message "The automatic credential constructor failed.  Please enter your Tanium credentials to continue."
		
			$credentialObject = New-Object System.Management.Automation.PSCredential -ArgumentList $($reference.taniumUser),$($password.password)
		}
		catch [System.Management.Automation.MethodInvocationException]
		{
			if ($Error[0].Exception.Message -like "*password* is null*")
			{
				Write-Log -Message "The password cannot be null." -Component "Core Initialization" -Type 3 -LogFile $scriptLogFile

				Write-Output "The password cannot be null."
			}
			else
			{
				Write-Log -Message "Unhandled exception. $Error[0].Exception.Message" -Component "Core Initialization" -Type 3 -LogFile $scriptLogFile

				Write-Output "Unhandled exception. $Error[0].Exception.Message"
			}
		}
		catch [System.Exception]
		{
			Write-Log -Message "Unhandled exception. $Error[0].Exception.Message" -Component "Core Initialization" -Type 3 -LogFile $scriptLogFile

			Write-Output "Unhandled exception. $Error[0].Exception.Message"
		}		
	}

	return $credentialObject
}