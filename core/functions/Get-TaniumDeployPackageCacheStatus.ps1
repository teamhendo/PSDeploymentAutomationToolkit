function Get-TaniumDeployPackageCacheStatus {
[CmdletBinding()]
param (
     [Parameter(Mandatory=$true, 
     ValueFromPipeline=$true)]
     [ValidateNotNull()]
     $PackageCacheLoop, 
     [Parameter(Mandatory=$true, 
     ValueFromPipeline=$true)]
     [ValidateNotNull()]
     $TaniumImportPackage,
     [Parameter(Mandatory=$true, 
     ValueFromPipeline=$true)]
     [ValidateNotNull()]
     $ScriptLogFile
)

     Begin {
          $cfgPackageCacheSleep = 10
          $x = 0
     }

     Process {
          try {
               do {
                    if ($x -lt 1) 
                    {
                         Write-Log -Component "Get-TaniumDeployPackageCacheStatus" `
                                   -LogFile $scriptLogFile `
                                   -Type 1 `
                                   -Message (-join ('Validating Package Cache Status: ',
                                   "$($taniumImportPackage.productVendor)",' ',
                                   "$($taniumImportPackage.productName)",' ',`
                                   "$($taniumImportPackage.productVersion)",'',
                                   "$($taniumImportPackage.architecture)")) 
                    }

                    $taniumImportPackage = Get-TaniumDeployPackage -ID $taniumImportPackage.id

                    Start-Sleep -Seconds $cfgPackageCacheSleep

                    $x++
               }
               until ($x -gt $PackageCacheLoop -or $taniumImportPackage.allFilesCachedOnTaniumServer -eq $true)

               if ($taniumImportPackage.allFilesCachedOnTaniumServer -eq $true){
                    Write-Log -Component "Get-TaniumDeployPackageCacheStatus" `
                              -Type 1 `
                              -LogFile $scriptLogFile `
                              -Message (-join ('Package Cache Validated: ',
                              "$($taniumImportPackage.productVendor)",' ',
                              "$($taniumImportPackage.productName)",' ',`
                              "$($taniumImportPackage.productVersion)",'',
                              "$($taniumImportPackage.architecture)")) 

                    Write-Log -Component "DeploymentAutomationToolkit" `
                              -Type 1 `
                              -LogFile $scriptLogFile `
                              -Message (-join ( 'Successfully Imported: ',
                              "$($taniumImportPackage.productVendor)",' ',
                              "$($taniumImportPackage.productName)",' ',
                              "$($taniumImportPackage.productVersion)",'',
                              "$($taniumImportPackage.architecture)"))
               }
               else {
                    Write-Log -Component "Get-TaniumDeployPackageCacheStatus" `
                              -Type 1 `
                              -LogFile $scriptLogFile `
                              -Message (-join ('Package Cache Error: ',
                              "$($taniumImportPackage.productVendor)",' ',
                              "$($taniumImportPackage.productName)",' ',`
                              "$($taniumImportPackage.productVersion)",'',
                              "$($taniumImportPackage.architecture)"))

                    Write-Log -Component "DeploymentAutomationToolkit" `
                              -Type 1 `
                              -LogFile $scriptLogFile `
                              -Message (-join ( 'Import Failure: ',
                              "$($taniumImportPackage.productVendor)",' ',
                              "$($taniumImportPackage.productName)",' ',
                              "$($taniumImportPackage.productVersion)",'',
                              "$($taniumImportPackage.architecture)"))
               }
          }
          catch [System.Net.WebException]
          {    
               switch ($Error[0].ErrorDetails.Message) 
               {
                    {$_ -like "*already exists*"} {
                         $errorMessage = $Error[0].ErrorDetails.Message | Out-String | ConvertFrom-Json

                         Write-Log -Component "Get-TaniumDeployPackageCacheStatus" `
                                   -LogFile ($scriptLogFile) `
                                   -Type 1 `
                                   -Message "$($($errorMessage.errors.description).replace('"',''))."

                         Remove-Variable errorMessage
                    }
                    {$_ -like "*Unable to find Software Package*"} {
                         Write-Log -Component "Get-TaniumDeployPackageCacheStatus" `
                                   -LogFile ($scriptLogFile) `
                                   -Type 1 `
                                   -Message "$($($errorMessage.errors.description).replace('"',''))."
                    }
                    Default 
                    {
                         Write-Log -Component "Get-TaniumDeployPackageCacheStatus" `
                                   -LogFile ($scriptLogFile) `
                                   -Type 1 `
                                   -Message "$($Error[0].ErrorDetails.Message)"
                    }
               }
          }
     }

     End {
          return $taniumImportPackage
     }
}