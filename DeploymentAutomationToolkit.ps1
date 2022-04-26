<#
.SYNOPSIS
	The PowerShell Deployment Automation Toolkit provides a way to deliver automated deployments through the Tanium Endpoint Management platform.
	# LICENSE #
	Copyright (C) 2020-2022 - Brent Henderson
	This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
	You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
#>

[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
    [pscredential] $CredentialObject,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("true","false")]
    [boolean] $DecommOnCompletion = $true,
    
    [Parameter(Mandatory=$true)]
	[ValidateSet('Alt','DEV','QA','PROD')]
    [string] $Environment = 'Alt',
    
    [ValidateSet("true","false")]
    $StartToday = [bool]$false,

    [ValidateSet("true","false")]
    [boolean] $QuickTest = $false
)

##*===============================================
##* VARIABLE DECLARATION & ENVIRONMENT STAGING
##*===============================================

$scriptDirectory = $PSScriptRoot

Write-Output "Script Directory: $($scriptDirectory)"

## Variables: Environment

##*=============================================
##* VARIABLE DECLARATION
##*=============================================

## Variables: Script Info
[version]$depAutoMainScriptVersion = [version]'0.5.5'

## Variables: Datetime and Culture
[datetime]$currentDateTime = Get-Date
[string]$currentDate = Get-Date -Date $currentDateTime -UFormat '%Y-%m-%d'

## Variables: Miscellaneous Runtime Dependencies
[System.Collections.ArrayList]$jobFailures = @()
[System.Collections.ArrayList]$galleryCatalog = @()
[System.Collections.ArrayList]$jobHandler = @()
[string]$scriptLogFile = $(-join ($scriptDirectory,'/logs/deploymentautomation.log'))

## Check for the existence of a log file and create one if absent

if (!(Test-Path -Path $scriptLogFile)) 
{
    New-Item -Path "$scriptDirectory/logs" -ItemType file -Name 'deploymentautomation.log' | Out-Null
}

## Dot source the required Deployment Automation Toolkit functions
if (Test-Path "$scriptDirectory/core/functions/") 
{
    try 
    {
        Get-ItemProperty -Path "$scriptDirectory/core/functions/*" -Include "*.ps1" | Select-Object -ExpandProperty FullName | ForEach-Object {. "$_"}

        Write-Log -Component "Core Initialization" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message "*******************************************************************************" 
        
        Write-Log -Component "Core Initialization" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message "*******************************************************************************" 

        Write-Log -Component "Core Initialization" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message "Deployment Automation Toolkit Version: [$depAutoMainScriptVersion]"

        Write-Log -Component "Core Initialization" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message "Working directory is [$scriptDirectory]" 

        Write-Log -Component "Core Initialization" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message "Operating Platform - Tanium" 

        Write-Log -Component "Core Initialization" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message (-join ('Operating Environment - ',$($Environment)))

        Write-Log -Component "Core Initialization" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message (-join ('Quick Test Utilized - ',$($QuickTest)))
        
        Get-ItemProperty  -Path "$scriptDirectory/core/functions/*" `
                          -Include "*.ps1" | `
                            Select-Object -ExpandProperty Name | `
                            ForEach-Object `
                            { Write-Log -Component "Core Initialization" `
                                        -Type 1 `
                                        -LogFile $scriptLogFile `
                                        -Message "Importing Function: $_ from $scriptDirectory/core/dependencies"
                            }
    }
    catch 
    {
        Write-Log -Component "Core Initialization" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message "Uncaught exception. $($Error[0]) - Exiting."
    }		    
}
else 
{
    Write-Log -Component "Core Initialization" `
              -Type 3  `
              -LogFile $scriptLogFile `
              -Message "Error:  The functions directory is missing or inaccessible: " +
                         "`n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" 
        
    ## Exit the script, returning the exit code
    
    if (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } else { Exit $mainExitCode }
}

if ($false -eq [bool]$(Get-Command -Module TanRest))
{
    try 
    {
        Write-Log -Component "Core Initialization" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message (-join ('Tanium TanREST Module Required: Importing')) 
        try 
        {
            Import-Module -Name TanREST -ErrorAction Stop   
        }
        catch [System.IO.FileNotFoundException] 
        {
            Write-Output 'The TanREST module could not be found. Please import the TanREST module and try again.'

            exit
        }
        

        if ($true -eq [bool]$(Get-Module -Name TanREST)) 
        {
            Write-Log -Component "Core Initialization" `
                      -Type 1 `
                      -LogFile $scriptLogFile `
                      -Message 'TanREST Module Import Successful' 
        }
    }
    catch 
    {
        Write-Log -Component "Core Initialization" `
                  -Type 3 `
                  -LogFile $scriptLogFile `
                  -Message "TanREST module not found. Exiting." 
        
        exit
    }
}

if ($false -eq [bool]$(Get-TaniumSavedWebSession -ErrorAction SilentlyContinue)) 
{
    if ($credentialObject)
    {
        [void]$(New-DASession -ScriptDirectory $scriptDirectory -Credential $credentialObject)
    }
    else 
    {
        [void]$(New-DASession -ScriptDirectory $scriptDirectory)
    }
}
            
Write-Log -Component "Core Initialization" `
          -Type 1 `
          -LogFile $scriptLogFile `
          -Message 'Importing Existing Tanium Deploy Packages' 

$taniumDeployPackages = Get-TaniumDeployPackage

if ($null -ne $taniumDeployPackages) {
    Write-Log -Component "Core Initialization" `
              -Type 1 `
              -LogFile $scriptLogFile `
              -Message 'Successfully imported Tanium Deploy Packages' 
}
else {
    Write-Log -Component "Core Initialization" `
              -Type 1 `
              -LogFile $scriptLogFile `
              -Message 'Failed to import Tanium Deploy Packages. Exiting.'

    exit
}

Write-Log -Component "Core Initialization" `
          -Type 1 `
          -LogFile $scriptLogFile `
          -Message 'Importing Tanium Package Gallery Contents' 

$taniumDeployGalleryCatalog = Get-TaniumDeployGalleryPackage

if ($null -ne $taniumDeployGalleryCatalog) {
    Write-Log -Component "Core Initialization" `
              -Type 1 `
              -LogFile $scriptLogFile `
              -Message 'Successfully imported Tanium Deploy Gallery Contents' 
}
else {
    Write-Log -Component "Core Initialization" `
              -Type 1 `
              -LogFile $scriptLogFile `
              -Message 'Failed to import Tanium Deploy Gallery Contents. Exiting.'

    exit
}

Write-Log -Component "Core Initialization" `
          -Type 1 `
          -LogFile $scriptLogFile `
          -Message 'Importing Tanium Computer Groups' 

$taniumComputerGroups = Get-TaniumCoreComputerGroup

if ($null -ne $taniumComputerGroups) {
    Write-Log -Component "Core Initialization" `
              -Type 1 `
              -LogFile $scriptLogFile `
              -Message 'Successfully imported Tanium Computer Groups' 
}
else {
    Write-Log -Component "Core Initialization" `
              -Type 1 `
              -LogFile $scriptLogFile `
              -Message 'Failed to import Tanium Computer Groups. Exiting.'

    exit
}

Write-Log -Component "Core Initialization" `
          -Type 1 `
          -LogFile $scriptLogFile `
          -Message 'Importing Tanium Patch Lists' 

$taniumPatchPatchLists = Get-TaniumPatchPatchlist

# Workaround for calls to Get-TaniumPatchPatchlist being intermittently empty without a given ID

if ($null -eq $taniumPatchPatchLists -or '' -eq $taniumPatchPatchLists) {
    $taniumPatchPatchLists = [System.Collections.Generic.List[object]]::new()

    $exit = $false
    $x = 1

    while ($exit -eq $false) {
        $tempObject = Get-TaniumPatchPatchlist -ID $x -ErrorAction SilentlyContinue
        
        if ($tempObject) {
            $taniumPatchPatchLists.Add($tempObject)

            $x++            
        }
        else {
            $exit = $true
        }

        Clear-Variable -Name tempObject
    }
}

if ($null -ne $taniumPatchPatchLists) {
    Write-Log -Component "Core Initialization" `
              -Type 1 `
              -LogFile $scriptLogFile `
              -Message 'Successfully imported Tanium Patch Lists' 
}
else {
    Write-Log -Component "Core Initialization" `
              -Type 1 `
              -LogFile $scriptLogFile `
              -Message 'Failed to import Tanium Patch Lists. Exiting.'

    exit
}
        
Write-Log -Message "Core initialization complete." -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile

##*===============================================
##* QUEUE MANAGER
##*===============================================

## Import active catalog items

Get-ChildItem -Path "$scriptDirectory/core/catalog/*" -Include *.json | `
              Select-Object -ExpandProperty FullName | `
              ForEach-Object {$galleryCatalog.Add($_)} | Out-Null

## Begin job queue management

Write-Log -Component "Queue Manager" `
          -Type 1 `
          -LogFile $scriptLogFile `
          -Message "Determining if there are pending jobs in the queue." 

if (Test-Path "$scriptDirectory/jobqueue") 
{
    $queuedJobs = Get-ChildItem -Path "$scriptDirectory/jobqueue/*" -Include *.json | Select-Object -ExpandProperty Fullname
    
    if ($queuedJobs.Count -ge 1) 
    {
        
        Write-Log -Component "Queue Manager" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message "Jobs found in the queue:  $($queuedJobs.Count)"
    }
    else 
    {
        
        Write-Log -Component "Queue Manager" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message "Jobs found in the queue:  0" 
    }
}
else 
{
    Write-Log -Component "Queue Manager" `
              -Type 3 `
              -LogFile $scriptLogFile `
              -Message "Error:  $scriptDirectory/jobqueue is missing or inaccessible.  Exiting." 
    
    exit
}
    
##*===============================================
##* JOB MANAGER
##*===============================================
    
## Import queued jobs into jobHandler variable

if ($($queuedJobs).Count -ge 1) 
{
    foreach ($job in $queuedJobs) 
    {
        $jobContent = Get-Content $job -Raw | Out-String | ConvertFrom-Json
       
        if ($($jobContent.jobStatus) -ne 'hold' -or $($jobContent.jobStatus) -ne 'complete') 
        {
            Write-Log -Component "Job Manager" `
                      -Type 1 `
                      -LogFile $scriptLogFile `
                      -Message (-join ('Job Discovered: ',
                        "$($jobContent.productVendor)",' ',
                        "$($jobContent.productName)",' ',
                        "$($jobContent.productVersion)",'',
                        "$($jobContent.architecture)"))
            
            $jobHandler.Add($jobContent) | Out-Null
        }
        else 
        {
            if ($($jobContent.jobStatus -eq 'hold')) 
            {
                Write-Log -Component "Job Manager" `
                          -Type 1 `
                          -LogFile $scriptLogFile `
                          -Message (-join ('Job Discovered [Hold]: ',
                            "$($jobContent.productVendor)",' ',
                            "$($jobContent.productName)",' ',
                            "$($jobContent.productVersion)",
                            "$($jobContent.architecture)")) 
            }
        }            
    }

    Clear-Variable -Name job

}

## Compare catalog items to active jobs, determine what items from the catalog require a job, add them to the jobHandler variable, and create a job if one doesn't already exist.

foreach ($galleryCatalogEntry in $galleryCatalog) 
{
    $tempContent = Get-Content $galleryCatalogEntry -Raw | Out-String | ConvertFrom-Json

    if ($jobHandler.productVendor -notcontains $tempContent.productVendor -or `
        $jobHandler.productName -notcontains $tempContent.productName) 
    {
        Write-Log -Component "Job Manager" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message (-join ('Job Required: ',
                    "$($tempContent.productVendor)",' ',
                    "$($tempContent.productName)",' ',
                    "$($tempContent.architecture)"))
        
        $tempGUID = New-Guid | Select-Object -ExpandProperty Guid
        
        $tempContent | Add-Member -NotePropertyName guid -NotePropertyValue "$tempGUID" -Force
        
        if ($tempContent.source -eq 'deployGallery')
        {
            $tempContent | Add-Member -NotePropertyName jobStatus -NotePropertyValue ('downloading') -Force
        }

        if ($tempContent.source -eq 'taniumPatch')
        {
            $tempContent | Add-Member -NotePropertyName jobStatus -NotePropertyValue ('deployment') -Force
        }
        
        $tempFileName = ('Tanium' + '-' + `
                        $environment + '-' + `
                        $($tempContent).productVendor).Replace(' ','') + '-' + `
                        $($tempContent.productName) + '-' + `
                        $($tempContent.architecture) + '-' + `
                        $tempGUID + `
                        '.json'
        
        $tempContent |  Add-Member -NotePropertyName jobFileLocation `
                        -NotePropertyValue (-join ("/jobqueue/","$tempFileName")) `
                        -Force
        
        Write-Log -Component "Job Manager" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message (-join ('Job Generated: ',
                    "$($tempContent.productVendor)",' ',
                    "$($tempContent.productName)",' ',
                    "$($tempContent.architecture)")) 
            
        
        $tempContent | ConvertTo-Json -Depth 100 | Out-File "$scriptDirectory/jobqueue/$tempFileName"

        if (Test-Path "$scriptDirectory/jobqueue/$tempFileName") 
        {
            Write-Log -Component "Job Manager" -Type 1 `
                      -LogFile $scriptLogFile `
                      -Message (-join ('Job Validated: ',
                        "$($tempContent.productVendor)",' ',
                        "$($tempContent.productName)",' ',
                        "$($tempContent.architecture)"))                
            
            Set-JSONProperty  -Path "$scriptDirectory/jobqueue/$tempFileName" `
                              -NoteProperty lastModified `
                              -Value (Get-Date -Format o | `
                                ForEach-Object { $_ -replace ":", "." })
        }
        else 
        {
            Write-Log -Component "Job Manager" `
                      -Type 3 `
                      -LogFile $scriptLogFile
                      -Message (-join ('Job Creation Failed: ',
                        "$($tempContent.productVendor)",' ',
                        "$($tempContent.productName)",' ',
                        "$($tempContent.architecture)"))
        }

        ##TODO - Validate that the job file was successfully created and log the results
        
        $jobHandler.Add($tempContent) | Out-Null

        Remove-Variable tempContent -ErrorAction SilentlyContinue

    }
}

##*===============================================
##* Package Management
##*===============================================

foreach ($job in $jobHandler) 
{
    ## Compare existing deployments to catalog entries, end those deployments if found and appropriate, and tag packages with a deletion date marker.
    if ($job.type -eq 'package')
    {
        Write-Log   -Component "DeploymentAutomationToolkit:PackageManagement" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message (-join ('Processing job: ',
                    "$($job.productVendor)",' ',
                    "$($job.productName)",' ',
                    "$($job.productVersion)",'',
                    "$($job.architecture)"))
        
        if ($job.jobStatus -eq 'downloading' -and $job.source -eq 'deployGallery')
        {
            $latestPackage = Get-LatestTaniumDeployPackage `
                             -Platform $job.platform `
                             -ProductVendor $job.productVendor `
                             -ProductName $job.productName `
                             -ScriptLogFile $scriptLogFile

            if ($latestPackage.importRequired -eq $true)
            {
                Write-Log -Component "DeploymentAutomationToolkit:PackageManagement" -Type 1 `
                          -LogFile $scriptLogFile `
                          -Message "Importing Package: $($latestPackage.name)"
                
                $taniumImportPackage = Import-TaniumDeployGalleryPackage -ID $latestPackage.softwarePackageId
                
                if ($taniumImportPackage) {
                    $taniumImportPackage.description    = "Imported by Deployment Automation Toolkit " + `
                                                          "on $currentDate as part of Job $($job.guid)"

                    $taniumImportPackage                = $taniumImportPackage | Set-TaniumDeployPackage

                    $job.currentSoftwarePackageEditId   = $taniumImportPackage.currentSoftwarePackageEditId
                    $job.currentVersion                 = $taniumImportPackage.productVersion
                    $job.previousSoftwarePackageId      = $taniumImportPackage.previousSoftwarePackageId
                    $job.previousVersion                = $latestPackage.previousVersion
                    $job.softwarePackageId              = $taniumImportPackage.id

                    $cacheValidationObject              =    Get-TaniumDeployPackageCacheStatus `
                                                            -PackageCacheLoop $job.packageCacheLoop `
                                                            -TaniumImportPackage $taniumImportPackage `
                                                            -ScriptLogFile $scriptLogFile
                }
                else {
                    Write-Log -Component "DeploymentAutomationToolkit:PackageManagement" `
                              -Type 2 -LogFile $scriptLogFile `
                              -Message (-join ('Placing job in Hold directory: ',
                                "$($cacheValidationObject.productVendor)",' ',
                                "$($cacheValidationObject.productName)",' ',
                                "$($cacheValidationObject.productVersion)",'',
                                "$($cacheValidationObject.architecture)")) 
                    
                    $removePath = (-join ($scriptDirectory, $($job.jobFileLocation)))
                    
                    $job.currentSoftwarePackageEditId = $latestPackage.currentSoftwarePackageEditId
                    $job.currentVersion               = $latestPackage.productVersion
                    $job.holdReason                   = 'importFailure'
                    $job.jobStatus                    = 'hold'
                    $job.jobFileLocation              = $job.jobFileLocation.Replace('/jobqueue/','/jobqueue/hold/')
                    $job.previousSoftwarePackageId    = $latestPackage.previousSoftwarePackageId
                    $job.previousVersion              = $latestPackage.previousVersion
                    $job.softwarePackageId            = $latestPackage.softwarePackageId

                    $job | ConvertTo-Json -Depth 100 | Out-File (-join ($scriptDirectory, $($job.jobFileLocation))) -Force
                    
                    $jobFailures.Add($job)

                    if (Test-Path -Path (-join ($scriptDirectory, $($job.jobFileLocation)))) {
                        Remove-Item -Path $removePath
                    }
                    
                    break
                }

                if ($cacheValidationObject.allFilesCachedOnTaniumServer -eq $true)
                {
                    Write-Log -Component "DeploymentAutomationToolkit:PackageManagement" `
                              -Type 1 `
                              -LogFile $scriptLogFile `
                              -Message (-join ('Job status updated to - deployment: ',
                                "$($cacheValidationObject.productVendor)",' ',
                                "$($cacheValidationObject.productName)",' ',
                                "$($cacheValidationObject.productVersion)",'',
                                "$($cacheValidationObject.architecture)"))
                    
                    $job | Add-Member -NotePropertyName jobStatus -NotePropertyValue ('deployment') -Force
                        
                    Set-JSONProperty -Path $(-join ($scriptDirectory, $($job.jobFileLocation))) -NoteProperty "jobStatus" -Value 'deployment'
                }
                else 
                {
                    Write-Log -Component "DeploymentAutomationToolkit:PackageManagement" `
                              -Type 2 -LogFile $scriptLogFile `
                              -Message (-join ('Placing job in Hold directory: ',
                                "$($cacheValidationObject.productVendor)",' ',
                                "$($cacheValidationObject.productName)",' ',
                                "$($cacheValidationObject.productVersion)",'',
                                "$($cacheValidationObject.architecture)")) 
                    
                    Remove-Item -Path (-join ($scriptDirectory, $($job.jobFileLocation)))
                    
                    $job.currentSoftwarePackageEditId = $latestPackage.currentSoftwarePackageEditId
                    $job.currentVersion               = $latestPackage.productVersion
                    $job.holdReason                   = 'cacheFailure'
                    $job.jobStatus                    = 'hold'
                    $job.jobFileLocation              = $job.jobFileLocation.Replace('/jobqueue/','/jobqueue/hold/')
                    $job.previousSoftwarePackageId    = $latestPackage.previousSoftwarePackageId
                    $job.previousVersion              = $latestPackage.previousVersion
                    $job.softwarePackageId            = $latestPackage.softwarePackageId

                    $jobFailures.Add($job)

                    $job | ConvertTo-Json -Depth 100 | Out-File (-join ($scriptDirectory, $($job.jobFileLocation))) -Force
                }
            }
            elseif ($latestPackage.importRequired -eq $false -and $latestPackage.contentCached -eq $true) 
            {
                Write-Log -Component "DeploymentAutomationToolkit:PackageManagement" -Type 1 `
                          -LogFile $scriptLogFile `
                          -Message "Package already present with cached content: $($latestPackage.name)"
                
                Write-Log -Component "DeploymentAutomationToolkit:PackageManagement" `
                          -Type 1 `
                          -LogFile $scriptLogFile `
                          -Message (-join ( 'Job status updated to - deployment: ',"$($latestPackage.Name)"))

                $job.currentSoftwarePackageEditId = $latestPackage.currentSoftwarePackageEditId
                $job.currentVersion               = $latestPackage.productVersion
                $job.jobStatus                    = 'deployment'
                $job.previousSoftwarePackageId    = $latestPackage.previousSoftwarePackageId
                $job.previousVersion              = $latestPackage.previousVersion
                $job.softwarePackageId            = $latestPackage.softwarePackageId

                $job | ConvertTo-Json -Depth 100 | Out-File (-join ($scriptDirectory, $($job.jobFileLocation))) -Force
            }
            elseif ($latestPackage.importRequired -eq $false -and $latestPackage.contentCached -eq $false) 
            {
                Write-Log -Component "DeploymentAutomationToolkit:PackageManagement" -Type 1 `
                          -LogFile $scriptLogFile `
                          -Message "Package already present but cache validation failed: $($latestPackage.name)"

                Write-Log -Component "DeploymentAutomationToolkit:PackageManagement" -Type 1 `
                          -LogFile $scriptLogFile `
                          -Message "Placing job in Hold directory: $($latestPackage.name)"
                
                Remove-Item -Path (-join ($scriptDirectory, $($job.jobFileLocation)))
                    
                $job.currentSoftwarePackageEditId = $latestPackage.currentSoftwarePackageEditId
                $job.currentVersion               = $latestPackage.productVersion
                $job.holdReason                   = 'cacheFailure'
                $job.jobStatus                    = 'hold'
                $job.jobFileLocation              = $job.jobFileLocation.Replace('/jobqueue/','/jobqueue/hold/')
                $job.previousSoftwarePackageId    = $latestPackage.previousSoftwarePackageId
                $job.previousVersion              = $latestPackage.previousVersion
                $job.softwarePackageId            = $latestPackage.softwarePackageId

                $jobFailures.Add($job)

                $job | ConvertTo-Json -Depth 100 | Out-File (-join ($scriptDirectory, $($job.jobFileLocation))) -Force
            }
        }

        if ($cacheValidationObject) {Clear-Variable -Name cacheValidationObject}
        if ($latestPackage) {Clear-Variable -Name latestPackage}
        if ($taniumImportPackage) {Clear-Variable -Name taniumImportPackage}
    }
}

# Loop jobFailures array to clean up jobHandler prior to more processing

foreach ($job in $jobFailures) {
    $jobHandler.Remove($job)
}

if ($jobHandler.source -contains 'deployGallery')
{
    Write-Log -Component "DeploymentAutomationToolkit:PackageManagement" -Type 1 `
              -LogFile $scriptLogFile `
              -Message "Updating Tanium Deploy Package catalog."

    [void]$(Update-TaniumDeployPackageCatalog)
}

##*===============================================
##* Time Management
##*===============================================

foreach ($job in $jobHandler) 
{
    Write-Log   -Component "DeploymentAutomationToolkit:TimeManagement" -Type 1 `
                -LogFile $scriptLogFile `
                -Message ("Determining deployment Start and Stop Times: " + `
                         $job.productVendor + ' ' + `
                         $job.productName + ' ' + `
                         $job.guid
                         )
     
    $job = Get-StartAndEndDates -Job $job -ScriptLogFile $scriptLogFile -StartToday $StartToday

    $job | ConvertTo-Json -Depth 100 | Out-File (-join ($scriptDirectory, $($job.jobFileLocation))) -Force
}

##*===============================================
##* Deployment Processing
##*===============================================

# Validate deployment information

foreach ($job in $jobHandler)
{

    [int]$ringCount = $($job | Get-Member | Where-Object {$_.name -like "ring*"}).count
    [int]$ringLoop = 1
    
    do 
    {
        New-Variable -Name (-join ('ring',$ringLoop)) -Value $ringLoop -Force
     
        $activeRing = Get-Variable -Name `
                      (-join ('ring',$ringLoop)) | `
                      Select-Object -ExpandProperty 'Name'

        Write-Log -Component "DeploymentAutomationToolkit:DeploymentProcessing" -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message ("Creating and validating deployment information for: " + `
                           $job.productVendor + ' ' + `
                           $job.productName + ' ' + `
                           $job.guid + ' ' + `
                           $activeRing
                           )

        if ($job.type -eq 'patch')
        {
            $job.$activeRing.patchListIdsWithLatestVersion = $taniumPatchPatchLists | Where-Object {$_.name -eq $job.$activeRing.patchListName} | Select-Object -ExpandProperty id

            $job.$activeRing.targetedComputerGroupIds = @([string]$($taniumComputerGroups | Where-Object {$_.name -eq $job.$activeRing.targetCriteria} | Select-Object -ExpandProperty id))
        }

        $job = Confirm-DeploymentData -Job $job -ScriptLogFile $scriptLogFile

        if ($false -eq $job.$activeRing.classValidated) 
        {
            Write-Log   -Component "DeploymentAutomationToolkit:DeploymentProcessing" `
                                -Type 2 -LogFile $scriptLogFile `
                                -Message (-join ('Placing job in Hold directory: ',
                                "$($job.productVendor)",' ',
                                "$($job.productName)",' ',
                                "$($job.productVersion)",'',
                                "$($job.architecture)")) 

            Remove-Item -Path (-join ($scriptDirectory, $($job.jobFileLocation)))
            
            $job.jobStatus          = 'hold'
            $job.holdReason         = 'classValidationFailure'
            $job.jobFileLocation    = $job.jobFileLocation.Replace('/jobqueue/','/jobqueue/hold/')

            $jobFailures.Add($job)

            $job | ConvertTo-Json -Depth 100 | Out-File (-join ($scriptDirectory, $($job.jobFileLocation))) -Force
        }

        $ringLoop++
    } 
    until ($ringLoop -gt $ringCount)
    
    $job | ConvertTo-Json -Depth 100 | Out-File (-join ($scriptDirectory, $($job.jobFileLocation))) -Force

    Remove-Variable activeRing
    Remove-Variable ringCount
    Remove-Variable ringLoop
    
}

# Loop jobFailures array to clean up jobHandler prior to more processing

foreach ($job in $jobFailures) {
    $jobHandler.Remove($job)
}

# Deployment object creation and validation

foreach ($job in $jobHandler) 
{
    if ($job.type -eq 'package') {
        Write-Log -Component "DeploymentAutomationToolkit:DeploymentProcessing" -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message ("Passing job to Gallery Package processor: " + `
                           $job.productVendor + ' ' + `
                           $job.productName + ' ' + `
                           $job.guid
                           )
        
        $job = Start-GalleryPackageDeploymentProcessing -Job $job -ScriptLogFile $scriptLogFile
    }
    
    if ($job.type -eq 'patch') {
        Write-Log -Component "DeploymentAutomationToolkit:DeploymentProcessing" -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message ("Passing job to Patch processor: " + `
                           $job.productVendor + ' ' + `
                           $job.productName + ' ' + `
                           $job.guid
                           )
        
        $job = Start-PatchDeploymentProcessing -Job $job -ScriptLogFile $scriptLogFile
    }
}

##*===============================================
##* Post-Deployment Notification & Closure
##*===============================================

# Validate deployment information

if ($jobFailures){
    foreach ($job in $jobFailures) {
        Export-Csv -InputObject $job -Path $scriptDirectory\logs\jobfailures.csv -NoTypeInformation -Append -Force
    }
}

if ($DecommOnCompletion){
    foreach ($job in $jobHandler) {
        if ($job.allRingsDeployed) {
            Write-Log -Component "DeploymentAutomationToolkit:PackageManagement" `
                      -Type 2 -LogFile $scriptLogFile `
                      -Message (-join ('Placing job in Decommissioned directory: ',
                      "$($job.productVendor)",' ',
                      "$($job.productName)",' ',
                      "$($job.productVersion)",'',
                      "$($job.architecture)")) 
            
            $removePath          = (-join ($scriptDirectory, $($job.jobFileLocation)))
            $job.holdReason      = 'notApplicable'
            $job.jobStatus       = 'complete'
            $job.jobFileLocation = $job.jobFileLocation.Replace('/jobqueue/','/jobqueue/decommissioned/')

            $job | ConvertTo-Json -Depth 100 | Out-File (-join ($scriptDirectory, $($job.jobFileLocation))) -Force

            if (Test-Path -Path (-join ($scriptDirectory, $($job.jobFileLocation)))) {
                Remove-Item -Path $removePath
            }
        }
    }
}