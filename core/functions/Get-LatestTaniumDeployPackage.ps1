function Get-LatestTaniumDeployPackage {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true, 
		ValueFromPipeline=$true)]
		[ValidateNotNull()]
		$Platform,
          [Parameter(Mandatory=$true, 
		ValueFromPipeline=$true)]
		[ValidateNotNull()]
		$ProductVendor,
          [Parameter(Mandatory=$true, 
		ValueFromPipeline=$true)]
		[ValidateNotNull()]
		$ProductName,  
		[Parameter(Mandatory=$true, 
		ValueFromPipeline=$true)]
		[ValidateNotNull()]
		$ScriptLogFile
	)
    
     Begin {
          $comparisonPackage =     $TaniumDeployPackages | 
                                   Where-Object { 
                                   $_.productVendor -eq $ProductVendor -and 
                                   $_.productName -eq $ProductName -and 
                                   $_.platform -eq $Platform} | 
                                   Sort-Object -Property productVersion -Descending | 
                                   Select-Object -First 1

          $latestGalleryPackage =  $taniumDeployGalleryCatalog | 
                                   Where-Object { 
                                   $_.productVendor -eq $ProductVendor -and 
                                   $_.productName -eq $ProductName -and 
                                   $_.platform -eq $Platform} | 
                                   Sort-Object -Property productVersion -Descending | 
                                   Select-Object -First 1         
     }

     Process {
          if ($comparisonPackage.productVersion -ne $latestGalleryPackage.productVersion) {
               if ($comparisonPackage.productVersion -gt $latestGalleryPackage.productVersion) {
                    $latestPackage = [PSCustomObject]@{
                         importRequired      = $false
                         name                = "$($comparisonPackage.productVendor ) $($comparisonPackage.productName) $($comparisonPackage.productVersion)"
                         packageEditId       = $($comparisonPackage.currentSoftwarePackageEditId)
                         packageId           = $($comparisonPackage.id)                         
                    }
               }
               else {
                    $latestPackage = [PSCustomObject]@{
                         importRequired      = $true
                         name                = "$($latestGalleryPackage.productVendor ) $($latestGalleryPackage.productName) $($latestGalleryPackage.productVersion)"
                         packageEditId       = $null
                         packageId           = $($latestGalleryPackage.id)
                    }
               }
          }
          else {
               $latestPackage = [PSCustomObject]@{
                    importRequired      = $false
                    name                = "$($comparisonPackage.productVendor ) $($comparisonPackage.productName) $($comparisonPackage.productVersion)"
                    packageEditId       = $($comparisonPackage.currentSoftwarePackageEditId)
                    packageId           = $($comparisonPackage.id)
               }
          }          
     }

     End {
          return $latestPackage
     }
}