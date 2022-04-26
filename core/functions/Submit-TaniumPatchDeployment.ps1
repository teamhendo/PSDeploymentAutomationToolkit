function Submit-TaniumPatchDeployment {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true, 
		ValueFromPipeline=$true,
		Position=0)]
		[ValidateNotNull()]
		$Data,
		[Parameter(Mandatory=$true, 
		ValueFromPipeline=$true,
		Position=1)]
		[ValidateNotNull()]
		$ScriptLogFile    
	)
    
     Begin {
          $deploymentOutcome       = [PSCustomObject]@{
               successfulDeployment     = $null
               deploymentObject         = $null
          }
     }

     Process {
          try
          {
               $deploymentObject = New-TaniumPatchDeployment -Data $Data
          }
          catch [System.Net.WebException]
          {    
               switch ($Error[0]) 
               {
                    {$_ -like "*invalid*target*"} 
                    {
                         Write-Log -Component "Submit-TaniumPatchDeployment" `
                                   -Type 3 `
                                   -LogFile $scriptLogFile `
                                   -Message ("The targeting criteria was invalid for : " + `
                                             $job.productVendor + ' ' + `
                                             $job.productName + ' ' + `
                                             $job.guid + ' ' + `
                                             $activeRing
                                             )
                    }
                    {$_ -like "*software*packages*distributed*"} 
                    {
                         Write-Log -Component "Submit-TaniumPatchDeployment" `
                                   -Type 3 `
                                   -LogFile $scriptLogFile `
                                   -Message ("The defined package ($($job.softwarePackageId)) does not exist or has not been distributed : " + `
                                             $job.productVendor + ' ' + `
                                             $job.productName + ' ' + `
                                             $job.guid + ' ' + `
                                             $activeRing
                                             )
                    }
                    Default 
                    {
                         Write-Log -Component "Submit-TaniumPatchDeployment" `
                                   -Type 3 `
                                   -LogFile $scriptLogFile `
                                   -Message ("Default error. $($Error[0]): " + `
                                             $job.productVendor + ' ' + `
                                             $job.productName + ' ' + `
                                             $job.guid + ' ' + `
                                             $activeRing
                                             )
                    }
               }
          }
          catch [System.Exception]
          {
               Write-Log -Component "Submit-TaniumPatchDeployment" `
                         -Type 3 `
                         -LogFile $scriptLogFile `
                         -Message  ("Default error. $($Error[0]): " + `
                                   $job.productVendor + ' ' + `
                                   $job.productName + ' ' + `
                                   $job.guid + ' ' + `
                                   $activeRing
                                   )
          }

          if ($deploymentObject) {
               Write-Log -Component "Submit-TaniumPatchDeployment" `
                         -Type 1 `
                         -LogFile $scriptLogFile `
                         -Message ("Deployment successfully created for: " + $deploymentObject.Name)
               
               $deploymentOutcome.successfulDeployment = $true
               $deploymentOutcome.deploymentObject     = $deploymentObject
          }
          else {
               Write-Log -Component "Submit-TaniumPatchDeployment" `
                         -Type 1 `
                         -LogFile $scriptLogFile `
                         -Message ("Failed to create deployment for: " + $Data.Name)
                         
               $deploymentOutcome.successfulDeployment = $false
          }
     }

     End {
          return $deploymentOutcome
     }
}