<#
.SYNOPSIS
	The PowerShell Deployment Automation Toolkit provides a way to deliver automated deployments through the Tanium Endpoint Management platform.
	# LICENSE #
	Copyright (C) 2020-2021 - Brent Henderson
	This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
	You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
#>

[CmdletBinding()]
Param (
	[ValidateSet("true","false")]
    $DecommOnCompletion = [bool]$true,
    [Parameter(Mandatory=$false)]
	[ValidateSet('Alt','DEV','QA','PROD')]
    $Environment = [string]'Alt',
    [ValidateSet("true","false")]
    $QuickTest = [bool]$false,
    [ValidateSet("true","false")]
    $StartToday = [bool]$false   
)

##*===============================================
##* VARIABLE DECLARATION & ENVIRONMENT STAGING
##*===============================================

if (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } else { $InvocationInfo = $MyInvocation }
$scriptDirectory = [string]$($(Split-Path -Path $($InvocationInfo.MyCommand.Definition) -Parent).Replace('\','/'))

## Variables: Environment

##*=============================================
##* VARIABLE DECLARATION
##*=============================================

## Variables: Script Info
[version]$depAutoMainScriptVersion = [version]'1.0.0'
[string]$depAutoMainScriptDate = '06/05/2021'

## Variables: Datetime and Culture
[datetime]$currentDateTime = Get-Date
[string]$currentDate = Get-Date -Date $currentDateTime -UFormat '%Y-%m-%d'

## Variables: Miscellaneous Runtime Dependencies
[System.Collections.ArrayList]$cacheFailures = @()
[System.Collections.ArrayList]$packageImportFailures = @()
[System.Collections.ArrayList]$galleryCatalog = @()
[System.Collections.ArrayList]$jobHandler = @()
[string]$scriptLogFile = $(-join ($scriptDirectory,'/logs/deploymentautomation.log'))

## Check for the existence of a log file and create one if absent

if (!(Test-Path -Path $scriptLogFile)) 
{
    New-Item -Path "$scriptDirectory/logs" -ItemType file -Name 'deploymentautomation.log' | Out-Null
}

## Dot source the required Deployment Automation Framework functions
if (Test-Path "$scriptDirectory/core/functions/") 
{
    try 
    {
        Get-ItemProperty -Path "$scriptDirectory/core/functions/*" -Include "*.ps1" | Select-Object -ExpandProperty FullName | ForEach-Object {. $_}
        
        Write-Log -Message "*******************************************************************************" -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile
        
        Write-Log -Message "*******************************************************************************" -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile
        
        Write-Log -Message "Working directory is [$scriptDirectory]" -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile
        
        Write-Log -Message 'Operating Platform - Tanium' -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile
        
        Write-Log -Message (-join ('Operating Environment - ',$($Environment))) -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile

        Write-Log -Message (-join ('Quick Test Utilized - ',$($QuickTest))) -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile
        
        Get-ItemProperty -Path "$scriptDirectory/core/functions/*" -Include "*.ps1" | Select-Object -ExpandProperty Name | ForEach-Object {Write-Log -Message "Importing Function: $_ from $scriptDirectory/core/dependencies" -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile }
    }
    catch {}		    
}
else 
{
    Write-Log -Message "Error:  The functions directory is missing or inaccessible: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -Component "Core Initialization" -Type 3  -LogFile $scriptLogFile
        
    ## Exit the script, returning the exit code
    
    if (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } else { Exit $mainExitCode }
}

switch ($Environment) 
{
    Alt 
    {
        try
        {
            $reference = Get-Content "$scriptDirectory/core/config/alt-reference.json" -Raw -ErrorAction Stop | Out-String | ConvertFrom-Json
        }
        catch [System.Management.Automation.ItemNotFoundException]
        {
            Write-Log -Message "alt-reference.json not found in $scriptDirectory/core/config/. Exiting." -Component "Core Initialization" -Type 3  -LogFile $scriptLogFile
            
            exit
        }
        catch [System.Net.WebException],[System.Exception]
        {
            $errorMessage = $error[0].Exception.Message
            
            Write-Log -Message "Unhandled exception encountered. Exiting." -Component "Core Initialization" -Type 3  -LogFile $scriptLogFile
            
            exit
        }                
    }
    DEV 
    { 
        try
        {
            $reference = Get-Content "$scriptDirectory/core/config/dev-reference.json" -Raw | Out-String | ConvertFrom-Json
        }
        catch [System.Management.Automation.ItemNotFoundException]
        {
            Write-Log -Message "dev-reference.json not found in $scriptDirectory/core/config/. Exiting." -Component "Core Initialization" -Type 3  -LogFile $scriptLogFile
            
            exit
        }
        catch [System.Net.WebException],[System.Exception]
        {
            $errorMessage = $error[0].Exception.Message
            
            Write-Log -Message "Unhandled exception encountered. Exiting." -Component "Core Initialization" -Type 3  -LogFile $scriptLogFile
            
            exit
        } 
    }
    QA 
    {
        try
        {
            $reference = Get-Content "$scriptDirectory/core/config/qa-reference.json" -Raw | Out-String | ConvertFrom-Json
        }
        catch [System.Management.Automation.ItemNotFoundException]
        {
            Write-Log -Message "qa-reference.json not found in $scriptDirectory/core/config/. Exiting." -Component "Core Initialization" -Type 3  -LogFile $scriptLogFile
            
            exit
        }
        catch [System.Net.WebException],[System.Exception]
        {
            $errorMessage = $error[0].Exception.Message
            
            Write-Log -Message "Unhandled exception encountered. Exiting." -Component "Core Initialization" -Type 3  -LogFile $scriptLogFile
            
            exit
        } 
    }
    PROD 
    {
        
        try
        {
            $reference = Get-Content "$scriptDirectory/core/config/prod-reference.json" -Raw | Out-String | ConvertFrom-Json
        }
        catch [System.Management.Automation.ItemNotFoundException]
        {
            Write-Log -Message "prod-reference.json not found in $scriptDirectory/core/config/. Exiting." -Component "Core Initialization" -Type 3  -LogFile $scriptLogFile
            
            exit
        }
        catch [System.Net.WebException],[System.Exception]
        {
            $errorMessage = $error[0].Exception.Message
            
            Write-Log -Message "Unhandled exception encountered. Exiting." -Component "Core Initialization" -Type 3  -LogFile $scriptLogFile
            
            exit
        } 
    }
}

if ($false -eq [bool]$(Get-Command -Module TanRest))
{
    try 
    {
        Write-Log -Message (-join ('Tanium TanREST Module Required: Importing')) -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile
        
        Import-Module -Name TanREST

        if ($true -eq [bool]$(Get-Module -Name TanREST)) 
        {
            Write-Log -Message 'TanREST Module Import Successful' -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile
        }
    }
    catch 
    {
        $errorMessage = $error[0].Exception.Message
        
        Write-Log -Message "TanREST module not found. Exiting." -Component "Core Initialization" -Type 3  -LogFile $scriptLogFile
        
        exit
    }
}

# TODO - Need to test $credentialObject and dump out of the script if it is null.

if ($false -eq [bool]$(Get-TaniumSavedWebSession -ErrorAction SilentlyContinue)) 
{
    $credentialObject = New-CredentialObject -ScriptDirectory $scriptDirectory -Reference $reference
    
    New-Session -scriptDirectory $scriptDirectory -reference $reference

    Remove-Variable -Name reference -ErrorAction SilentlyContinue
}
            
Write-Log -Message 'Importing Existing Tanium Deploy Packages' -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile

$taniumDeployPackages = Get-TaniumDeployPackage

Write-Log -Message 'Importing Tanium Package Gallery Contents' -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile

$taniumDeployGalleryCatalog = Get-TaniumDeployGalleryPackage

Write-Log -Message 'Importing Tanium Core Computer Groups' -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile

$taniumComputerGroups = Get-TaniumCoreComputerGroups
        
Write-Log -Message "Core initialization complete." -Component "Core Initialization" -Type 1 -LogFile $scriptLogFile

##*===============================================
##* QUEUE MANAGER
##*===============================================

## Import active catalog items

Get-ChildItem -Path "$scriptDirectory/core/catalog/*" -Include *.json | Select-Object -ExpandProperty FullName | ForEach-Object {$galleryCatalog.Add($_)} | Out-Null

## Begin job queue management

Write-Log   -Component "Queue Manager" `
            -Type 1 `
            -LogFile $scriptLogFile `
            -Message "Determining if there are pending jobs in the queue." 

if (Test-Path "$scriptDirectory/jobqueue") 
{
    $queuedJobs = Get-ChildItem -Path "$scriptDirectory/jobqueue/*" -Include *.json | Select-Object -ExpandProperty Fullname
    
    if ($queuedJobs.Count -ge 1) {
        
        Write-Log   -Component "Queue Manager" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message "Jobs found in the queue:  $($queuedJobs.Count)"

    }
    
    else {
        
        Write-Log -Message "Jobs found in the queue:  0" -Component "Queue Manager" -Type 1 -LogFile $scriptLogFile

    }
}
else 
{
    Write-Log -Message "Error:  $scriptDirectory/jobqueue is missing or inaccessible." -Component "Queue Manager" -Type 3 -LogFile $scriptLogFile
    
    Write-Log -Message "Error:  Exiting script." -Component "Queue Manager" -Type 3 -LogFile $scriptLogFile
    
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
            Write-Log   -Component "Job Manager" `
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
                Write-Log   -Component "Job Manager" `
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
        Write-Log   -Component "Job Manager" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message (-join ('Job Required: ',
                    "$($tempContent.productVendor)",' ',
                    "$($tempContent.productName)",' ',
                    "$($tempContent.architecture)"))
        
        $tempGUID = New-Guid | Select-Object -ExpandProperty Guid
        
        $tempContent | Add-Member -NotePropertyName guid -NotePropertyValue "$tempGUID" -Force
        
        $tempContent | Add-Member -NotePropertyName jobStatus -NotePropertyValue ('downloading') -Force
        
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
        
        Write-Log   -Component "Job Manager" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message (-join ('Job Generated: ',
                    "$($tempContent.productVendor)",' ',
                    "$($tempContent.productName)",' ',
                    "$($tempContent.architecture)")) 
            
        
        $tempContent | ConvertTo-Json | Out-File "$scriptDirectory/jobqueue/$tempFileName"

        if (Test-Path "$scriptDirectory/jobqueue/$tempFileName") 
        {
            Write-Log   -Component "Job Manager" -Type 1 `
                        -LogFile $scriptLogFile `
                        -Message (-join ('Job Validated: ',
                        "$($tempContent.productVendor)",' ',
                        "$($tempContent.productName)",' ',
                        "$($tempContent.architecture)"))                
            
            Set-JSONProperty    -Path "$scriptDirectory/jobqueue/$tempFileName" `
                                -NoteProperty lastModified `
                                -Value (Get-Date -Format o | `
                                ForEach-Object { $_ -replace ":", "." })
        }
        else 
        {
            Write-Log   -Component "Job Manager" `
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

Read-Host -Prompt 'Give me a break'

##*===============================================
##* Time Management
##*===============================================

if ($StartToday -eq $false -or $null -eq $StartToday)
{
    if ($(Get-PatchTuesday) -ge $(Get-Date))
    {
        $patchTuesdayOrToday = Get-PatchTuesday
    }
    else 
    {
        if ($(Get-Date).Month -ne '12'){
            $patchTuesdayOrToday =  Get-PatchTuesday `
                                    -Month $($(Get-Date).AddMonths(1).Month) `
                                    -Year $(Get-Date).Year
        }
        else
        {
            $patchTuesdayOrToday =  Get-PatchTuesday `
                                    -Month $($(Get-Date).AddMonths(1).Month) `
                                    -Year $($(Get-Date).Year + 1)
        }
    }
}
else 
{
    $patchTuesdayOrToday = Get-Date
}

##*===============================================
##* Package Management
##*===============================================

foreach ($job in $jobHandler) 
{
    ## Compare existing deployments to catalog entries, end those deployments if found and appropriate, and tag packages with a deletion date marker.
    if ($job.type -eq 'package')
    {
        Write-Output "Processing Job: $($job.productVendor) $($job.productName) $($job.architecture) $($job.guid)"
        
        if ($job.jobStatus -eq 'downloading' -and $job.source -eq 'deployGallery')
        {
            try {
                $latestPackage =    Get-LatestTaniumDeployPackage `
                                    -Platform $job.platform `
                                    -ProductVendor $productVendor `
                                    -ProductName $productName `
                                    -ScriptLogFile $scriptLogFile
            }
            catch {
                # TODO - Observe function for failure contingencies
            }

            if ($latestPackage.importRequired -eq $true){
                Write-Log   -Component "DeploymentAutomationToolkit:PackageManagement" -Type 1 `
                            -LogFile $scriptLogFile `
                            -Message "Importing Package: $($latestPackage.name)"
                
                try {
                    $taniumImportPackage = Import-TaniumDeployGalleryPackage -ID $latestPackage.packageId -Verbose  
                }
                catch {
                    $packageImportFailures.Add($job)
                    break
                }
                
                $taniumImportPackage.description    = "Imported by Deployment Automation Framework " + `
                                                      "on $currentDate as part of Job $($job.guid)"

                $taniumImportPackage | Set-TaniumDeployPackage | Out-Null

                $job.currentSoftwarePackageEditId   = $taniumImportPackage.currentSoftwarePackageEditId
                $job.currentVersion                 = $taniumImportPackage.productVersion
                $job.previousSoftwarePackageId      = $taniumImportPackage.previousSoftwarePackageId
                $job.previousVersion                = $latestPackage.previousVersion
                $job.softwarePackageId              = $taniumImportPackage.id

                $cacheValidationObject =    Get-TaniumDeployPackageCacheStatus `
                                            -PackageCacheLoop $job.packageCacheLoop `
                                            -TaniumImportPackage $taniumImportPackage `
                                            -ScriptLogFile $scriptLogFile

                if ($cacheValidationObject.allFilesCachedOnTaniumServer -eq $true){
                    Write-Log   -Component "DeploymentAutomationToolkit:PackageManagement" `
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
                else {
                    Write-Log   -Component "DeploymentAutomationToolkit:PackageManagement" `
                                -Type 2 -LogFile $scriptLogFile `
                                -Message (-join ('Placing job in Hold directory: ',
                                "$($cacheValidationObject.productVendor)",' ',
                                "$($cacheValidationObject.productName)",' ',
                                "$($cacheValidationObject.productVersion)",'',
                                "$($cacheValidationObject.architecture)")) 
                    
                    $cacheFailures.Add($job)

                    Remove-Item -Path (-join ($scriptDirectory, $($job.jobFileLocation)))
                    
                    $job.currentSoftwarePackageEditId   = $latestPackage.currentSoftwarePackageEditId
                    $job.currentVersion                 = $latestPackage.productVersion
                    $job.jobStatus                      = 'hold'
                    $job.jobFileLocation                = $job.jobFileLocation.Replace('/jobqueue/','/jobqueue/hold/')
                    $job.previousSoftwarePackageId      = $latestPackage.previousSoftwarePackageId
                    $job.previousVersion                = $latestPackage.previousVersion
                    $job.softwarePackageId              = $latestPackage.softwarePackageId

                    $job | ConvertTo-Json | Out-File (-join ($scriptDirectory, $($job.jobFileLocation))) -Force
                }
            }
            elseif ($latestPackage.importRequired -eq $false -and $latestPackage.allFilesCachedOnTaniumServer -eq $true) {
                Write-Log   -Component "DeploymentAutomationToolkit:PackageManagement" -Type 1 `
                            -LogFile $scriptLogFile `
                            -Message "Package already present with cached content: $($latestPackage.name)"
                
                Write-Log   -Component "DeploymentAutomationToolkit:PackageManagement" `
                            -Type 1 `
                            -LogFile $scriptLogFile `
                            -Message (-join ('Job status updated to - deployment: ',
                            "$(latestPackage.Name)"))

                $job.currentSoftwarePackageEditId   = $latestPackage.currentSoftwarePackageEditId
                $job.currentVersion                 = $latestPackage.productVersion
                $job.jobStatus                      = 'deployment'
                $job.previousSoftwarePackageId      = $latestPackage.previousSoftwarePackageId
                $job.previousVersion                = $latestPackage.previousVersion
                $job.softwarePackageId              = $latestPackage.softwarePackageId

                $job | ConvertTo-Json | Out-File (-join ($scriptDirectory, $($job.jobFileLocation))) -Force
            }
            elseif ($latestPackage.importRequired -eq $false -and $latestPackage.allFilesCachedOnTaniumServer -eq $true) {
                Write-Log   -Component "DeploymentAutomationToolkit:PackageManagement" -Type 1 `
                            -LogFile $scriptLogFile `
                            -Message "Package already present but cache validation failed: $($latestPackage.name)"

                Write-Log   -Component "DeploymentAutomationToolkit:PackageManagement" -Type 1 `
                            -LogFile $scriptLogFile `
                            -Message "Placing job in Hold directory: $($latestPackage.name)"
                
                $cacheFailures.Add($job)
            }
        }

        if ($cacheValidationObject) {Clear-Variable -Name cacheValidationObject}
        if ($latestPackage) {Clear-Variable -Name latestPackage}
        if ($taniumImportPackage) {Clear-Variable -Name taniumImportPackage}
    }
}

foreach ($failure in $cacheFailures){
    $jobHandler.Remove($failure)
}

##*===============================================
##* Deployment Processing
##*===============================================

foreach ($job in $jobHandler) 
{
    if ($job.jobStatus -eq 'deployment')
    {
        ##*===============================================
        ##* Tanium Deploy Gallery Deployment 
        ##*===============================================				
            
        [int]$ringCount = $($job | Get-Member | Where-Object {$_.name -like "ring*"}).count
        
        [int]$ringLoop = 1

        do 
        {
            New-Variable -Name (-join ('ring',$ringLoop)) -Value $ringLoop -Force
        
            $activeRing = Get-Variable -Name (-join ('ring',$ringLoop)) | Select-Object -ExpandProperty 'Name'
        
            $deploymentTarget = $taniumComputerGroups | Where-Object {$_.name -match "$($job.$activeRing.targetCriteria)"}

            switch ($job.type) 
            {
                package 
                {
                    $global:deploymentErrorObject = @()
                    
                    if ($null -eq $job.$activeRing.deployedOn) 
                    {
                        $startDate = $currentDate
                        $startTime = '21:00'

                        Write-Log -Message (-join ('Creating Deployment For: ',"$($job.productVendor)",' ',"$($job.productName)",' ',`
                            "$($job.productVersion)",'',"$($job.architecture)"," $($job.guid) ",$activeRing)) -Component "Job Manager" -Type 1 -LogFile $scriptLogFile
                    
                        if ($null -ne $job.$activeRing.startDateOffsetInDays -or $job.$activeRing.deploymentStartTime -ne '21:00') 
                        {
                            if ($null -ne $job.$activeRing.startDateOffsetInDays) 
                            {
                                $startDate = $($patchTuesdayOrToday).AddDays($job.$activeRing.startDateOffsetInDays).ToString("yyyy-MM-dd")
                            }
                            
                            if ($job.$activeRing.deploymentStartTime -ne '21:00') 
                            {
                                $startTime = $job.$activeRing.deploymentStartTime
                            }
                        }

                        if ($job.$activeRing.type -eq 'single')
                        {
                            $stopDate = $($patchTuesdayOrToday).AddDays($($job.$activeRing.startDateOffsetInDays) + `
                                ($job.$activeRing.deploymentLengthInDays)).ToString("yyyy-MM-dd")
                            $stopTime = $job.$activeRing.deploymentStopTime
                        }

                        $startString = -join ("$startDate",'T',"$startTime",':00.000Z')

                        $stopString = -join ("$stopDate",'T',"$stopTime",':00.000Z')
                        
                        $deploymentData = [hashtable]@{
                            currentSoftwarePackageEditId    = $job.currentSoftwarePackageEditId
                            description                     = "Created by Deployment Automation Framework on $currentDate as part of Job $($job.guid)"
                            downloadImmediately             = "$($job.$activeRing.downloadImmediately)"
                            endTime                         = "$stopString"
                            eussAvailableBeforeStart        = "$($job.$activeRing.eussAvailableBeforeStart)"
                            name                            = -join ("PSDAT - ",`
                                                                "$($job.productVendor)",' ',`
                                                                "$($job.productName)",' ',`
                                                                "$($job.currentVersion)",' ',`
                                                                "to $($deploymentTarget.name)",`
                                                                ' - ',`
                                                                $job.guid)
                            overrideMaintenanceWindows      = "$($job.$activeRing.overrideMaintenanceWindows)"
                            operation                       = "$($job.$activeRing.operation)"
                            restart                         = "$($job.$activeRing.restart)"
                            startTime                       = "$startString"
                            softwarePackageId               = "$($job.softwarePackageId)"
                            target= [PSCustomObject]@{
                                computerGroupIds            = @($($deploymentTarget.id))
                                questionGroupIds            = @()
                            }
                            type                            = "$($job.$activeRing.type)"
                            useTaniumClientTimeZone         = 'true'
                       }
                        
                        $deploymentErrorObject += $deploymentData

                        try
                        {
                            $deployment = New-TaniumDeployDeployment -Data $deploymentData
                        }
                        catch [System.Net.WebException]
                        {    
                            switch ($Error[0]) 
                            {
                                {$_ -like "*invalid*target*"} 
                                {
                                    Write-Log -Message "The targeting criteria was invalid." -Component "Job Manager" -Type 3 -LogFile $scriptLogFile

                                    $deploymentErrorObject += $deploymentData
                                }
                                {$_ -like "*software*packages*distributed*"} 
                                {
                                    Write-Log -Message "The defined package ($($deploymentData.softwarePackageId)) does not exist or has not been distributed." -Component "Job Manager" -Type 3 -LogFile $scriptLogFile

                                    $deploymentErrorObject += $deploymentData
                                }
                                Default 
                                {
                                    Write-Log -Message "$($Error[0])" -Component "Job Manager" -Type 3 -LogFile $scriptLogFile

                                    $deploymentErrorObject += $deploymentData
                                }
                            }
                        }
                        catch [System.Exception]
                        {
                            Write-Host "Other exception"

                            $deploymentErrorObject += $deploymentData
                        }                                                            
                        
                        if ($deployment.statusLabel -eq 'Active' -or $deployment.statusLabel -eq 'Scheduled') 
                        {
                            $job.$activeRing | Add-Member -NotePropertyName deployedOn -NotePropertyValue $deployment.createdAt -Force
                        
                            $job.$activeRing | Add-Member -NotePropertyName lastStatus -NotePropertyValue $deployment.statusLabel -Force
                        
                            $job.$activeRing | Add-Member -NotePropertyName deploymentID -NotePropertyValue $deployment.id -Force
                        
                            $job | Add-Member -NotePropertyName jobStatus -NotePropertyValue 'complete' -Force
                        
                            $job | ConvertTo-Json | Out-File "$scriptDirectory/$($job.jobFileLocation)" -Force
                        
                            Write-Log -Message (-join ('Deployment Successfully Created: ',"$($job.productVendor)",' ',"$($job.productName)",' ',`
                                "$($job.productVersion)",'',"$($job.architecture)"," $($job.guid) ",$activeRing)) -Component "Job Manager" -Type 1 -LogFile $scriptLogFile
                        
                            if ($activeRing -like "*$ringCount*" -and $null -ne $($job.$activeRing.deployedOn)) 
                            {
                                $job | Add-Member -NotePropertyName allRingsDeployed -NotePropertyValue 'true' -Force
                            
                                $job | ConvertTo-Json | Out-File "$scriptDirectory/$($job.jobFileLocation)" -Force
                                    
                                if ($DecommOnCompletion -eq $true)
                                {
                                    Set-JSONProperty -Path $(-join ($scriptDirectory, $($job.jobFileLocation))) -NoteProperty "jobFileLocation" -Value "$scriptDirectory/jobqueue/decommissioned"
                                    
                                    Start-Sleep -Seconds 3

                                    Move-Item -Path (-join ($scriptDirectory, $($job.jobFileLocation))) -Destination "$scriptDirectory/jobqueue/decommissioned" -Force
                                }
                                

                            }
                        }
                        
                        if ($Notify -eq $true){
 
                            Write-Log -Message 'Adding job to deployment array for email notification.' -Component "Job Manager" -Type 1 -LogFile $scriptLogFile
                        
                        }
                        
                        if ($QuickTest -eq $true){
                            Write-Log -Message 'Beginning 5 second cooldown for deployment processing.' -Component "Job Manager" -Type 1 -LogFile $scriptLogFile
                            
                            Start-Sleep -Seconds 5
                        }
                        else {
                            Write-Log -Message 'Beginning 120 second cooldown for deployment processing.' -Component "Job Manager" -Type 1 -LogFile $scriptLogFile
        
                            Start-Sleep -Seconds 120
                        }
                    }  
                    else 
                    {
                        Write-Log -Message (-join ('Ongoing Deployment Detected: ',"$($job.productVendor)",' ',"$($job.productName)",' ',`
                                "$($job.productVersion)",'',"$($job.architecture)"," $($job.guid) ",$activeRing)) -Component "Job Manager" -Type 1 -LogFile $scriptLogFile
                    }              

                    Clear-Variable -Name activeRing -ErrorAction SilentlyContinue
                    Clear-Variable -Name deployment -ErrorAction SilentlyContinue
                    Clear-Variable -Name deploymentData -ErrorAction SilentlyContinue -Verbose
                    Clear-Variable -Name jobFileName -ErrorAction SilentlyContinue
                    Clear-Variable -Name taniumCatalogPkg -ErrorAction SilentlyContinue
                    Clear-Variable -Name taniumImportPackage -ErrorAction SilentlyContinue
                }
                update 
                {
                    #0.0.2
                }
            }
                            
            $ringLoop++
        }
        until ($ringLoop -gt $ringCount)
    
        Clear-Variable ringCount
        Clear-Variable ringLoop
    }
}