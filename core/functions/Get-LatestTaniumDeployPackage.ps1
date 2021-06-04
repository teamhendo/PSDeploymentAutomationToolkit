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
          $comparisonPackage =    $TaniumDeployPackages | 
                                   Where-Object { 
                                   $_.productVendor -eq $ProductVendor -and 
                                   $_.productName -eq $ProductName -and 
                                   $_.platform -eq $Platform} | 
                                   Tee-Object -Variable previousPackage |
                                   Sort-Object -Property productVersion -Descending | 
                                   Select-Object -First 1

          $latestGalleryPackage =  $taniumDeployGalleryCatalog | 
                                   Where-Object { 
                                   $_.productVendor -eq $ProductVendor -and 
                                   $_.productName -eq $ProductName -and 
                                   $_.platform -eq $Platform} | 
                                   Sort-Object -Property productVersion -Descending | 
                                   Select-Object -First 1
                                   
          $previousPackage =       $previousPackage | 
                                   Sort-Object -Property productVersion -Descending |
                                   Select-Object -Skip 1 |
                                   Select-Object -First 1                                   
     }

     Process {
          if ($comparisonPackage.productVersion -ne $latestGalleryPackage.productVersion) {
               if ($comparisonPackage.productVersion -gt $latestGalleryPackage.productVersion) {
                    $latestPackage = [PSCustomObject]@{
                         contentCached                = $comparisonPackage.allFilesCachedOnTaniumServer
                         currentSoftwarePackageEditId = $comparisonPackage.currentSoftwarePackageEditId
                         importRequired               = $false
                         name                         = "$($comparisonPackage.productVendor) $($comparisonPackage.productName) $($comparisonPackage.productVersion)"
                         previousSoftwarePackageId    = $previousPackage.id
                         previousVersion              = $previousPackage.productVersion
                         productVersion               = $comparisonPackage.productVersion
                         softwarePackageId            = $comparisonPackage.id
                    }
               }
               else {
                    $latestPackage = [PSCustomObject]@{
                         contentCached                = $latestGalleryPackage.allFilesCachedOnTaniumServer
                         currentSoftwarePackageEditId = $latestGalleryPackage.currentSoftwarePackageEditId
                         importRequired               = $true
                         name                         = "$($latestGalleryPackage.productVendor) $($latestGalleryPackage.productName) $($latestGalleryPackage.productVersion)"
                         previousSoftwarePackageId    = $comparisonPackage.id
                         previousVersion              = $comparisonPackage.productVersion
                         productVersion               = $latestGalleryPackage.productVersion
                         softwarePackageId            = $latestGalleryPackage.id
                    }
               }
          }
          else {
               $latestPackage = [PSCustomObject]@{
                    contentCached                = $comparisonPackage.allFilesCachedOnTaniumServer
                    currentSoftwarePackageEditId = $comparisonPackage.currentSoftwarePackageEditId
                    importRequired               = $false
                    name                         = "$($comparisonPackage.productVendor) $($comparisonPackage.productName) $($comparisonPackage.productVersion)"
                    previousSoftwarePackageId    = $previousPackage.id
                    previousVersion              = $previousPackage.productVersion
                    productVersion               = $comparisonPackage.productVersion
                    softwarePackageId            = $comparisonPackage.id
               }
          }          
     }

     End {
          return $latestPackage
     }
}