# PowerShell Deployment Automation Toolkit

* Author: Brent Henderson
* Release Date: 06/10/2021
* Version: 0.5.1

## Introduction
### __Toolkit Overview__

The PowerShell Deployment Automation Toolkit provides a way to deliver automated deployments through the Tanium Endpoint Management platform.

### __Features__

This script manages the import and deployment of Software Gallery packages for the Tanium Endpoint Management platform. The tool currently provides the following functionality:

* Automated API session creation mechanism with manual fallback
* Catalog-driven for ease of customization
* Support for multiple environments with minimal administrative overhead
* Automated Tanium Package Gallery package imports
* Automated deployment creation to deployment rings designated in catalog items
* PowerShell classes to validate deployment data structures prior to API submission
* Support for Pre/Post Notification options with Single and Ongoing deployments
* Independently configurable rings (Eg, one ring can be a silent, Single deployment whereas the next could be an Ongoing deployment with prompts
* Patch Tuesday offset configuration for deployments
* CMTrace/OneTrace-compatible logging

### __Dependencies__

The TanREST PowerShell module is required and cannot currently be distributed by anyone other than Tanium.  Please contact your Technical Account Manager to acquire and install the latest version of TanREST.

### __License__

PowerShell Deployment Automation Framework - Provides a way to deliver automated deployments through the Tanium Endpoint Management platform.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

### __Usage__

````
powershell.exe -File '\\pathToFile\DeploymentAutomationToolkit.ps1'
````

````
powershell.exe -File '\\pathToFile\DeploymentAutomationToolkit.ps1' -Environment [[Alt],[Dev],[Prod],[QA]]
````

````
powershell.exe -File 'c:\pathToFile\DeploymentAutomationToolkit.ps1' -Environment 'Alt' -QuickTest $true -StartToday $true
````

````
$credentialObject = Get-Credential

powershell.exe -File 'c:\pathToFile\DeploymentAutomationToolkit.ps1' -Environment 'Alt' -QuickTest $true -StartToday $true -CredentialObject $credentialObject
````

### __Quick Start__

1. Configure reference file(s) for environment(s) under scriptRoot\core\config
2. Encrypted credentials may be stored in scriptRoot\core\config as tanium__ENV__Cred.txt (Not Recommended or Required for Production; $credentialObject = Get-Credential can be leveraged instead prior to execution as shown above)
3. Configure json catalog files under scriptRoot\core\catalog\repo (Examples of each potential configuration are provided)
4. Promote configured json catalog items to scriptRoot\core\catalog (Only the catalog items at the root of this directory will be processed)
5. Call script with desired environmental target

Example 1: The ConvertFrom-SecureString cmdlet converts a secure string into an encrypted standard string.  

````PowerShell
(Get-Credential).password | ConvertFrom-SecureString | Out-File "$scriptDirectory\core\config\tanium[[Alt],[Dev],[Prod],[QA]]Cred.txt"
````

### __Script Parameters__

Parameters|Description
--------------|--------------
CredentialObject (Optional)| Allows the user to establish a SecureString credential object prior to invocation of the tool.  By default, the Deployment Automation Toolkit will attempt to build credentials from a saved SecureString object if this is not provided.
DecommOnCompletion (Optional)| Designates whether or not jobs should be decommissioned once all rings are deployed; defaults to $true. If set to $false, jobs will remain in the root/jobqueue/ directory and no subsequent jobs for that software will proceed until the job is manually copied to the root/jobqueue/decommissioned/ directory.
Environment (Optional)| Designates the operating environment for the script to execute upon.  Jobs from multiple environments can coexist so back-to-back executions from multiple environments will function appropriately.  The default value is 'Alt'.
QuickTest (Optional)| Designates whether or not an abbreviated run should be facilitated; defaults to $false as a precaution.
StartToday| Designates whether or not the startDateOffsetInDays value in catalog items will offset relative to the runtime date or the next Patch Tuesday; defaults to $false.

### __JSON Catalog Keys | Tanium Package Deployments__

Note: Any null values in the example files under /core/catalog/repo denote values that will be established at runtime by the toolkit itself.  Users should not modify null values.

Keys|Description
--------------|--------------
allRingsDeployed| Indicates whether or not all defined rings within the job have been deployed.
architecture| Architecture of the package to be deployed. Valid entries are [x64],[x86],[any].
contentAcquired| Indicates whether or not the content for the package has been cached.
currentVersion| Reflects current software version for a given package that is available.
currentSoftwarePackageEditId| The current software package object version.
deployedObjectEditId| Functionally identical to currentSoftwarePackageEditId (current is used in package metadata; deployedObjectEditId is used to create deployments).
frameworkCatalogName| The name of the source catalog item that the job was created to address.  Must be the exact name; see examples.
guid| The unique GUID assigned to the job at runtime.
holdReason| The reason, if any, why a package was placed in a hold state.
jobFileLocation| The current location of the job file.    
jobStatus| The current status of the job.
lastModified| Indicates the last time the Toolkit modified a given job file.
packageCacheLoop| An integer value indicating how many loops the package cache logic should take.  Each loop is 10 seconds so a value of 30 would allow for a maximum of 5 minutes before the job was placed in a hold state.
platform| The platform that the job is targeted toward. Valid values are [windows] or [macos].
previousSoftwarePackageId| The previous package ID of the software that is being deployed by a given job. This property was previously named previousPackageID but amended to align more closely with Tanium object properties.
productName| The product name of the software being deployed by a given job.
productVendor| The product vendor of the software being deployed by a given job.
ring#| Deployment rings (ring1, ring2, etc.) are objects with their own subkeys that define the pertinent details of a deployment.  The subkeys are detailed below.
softwarePackageId| The current package ID of the package being deployed by a given job. This property was previously named packageId but amended to align with Tanium object properties.
source| The source property denotes the source from which the package content will be acquired; the only recognized value currently is deployGallery.
type| The type key denotes what is being deployed by the job; the only recognized value currently is package.

### __JSON Catalog - Subkeys of ring# | Tanium Package Deployments__

Keys|Description
--------------|--------------
class | Denotes the class of the ring that is being deployed.  Valid values are [OngoingPackageDeploymentSilent],[OngoingPackageWithPostAndPre],[OngoingPackageWithPostNoPre],[OngoingPackageWithPreNoPost],[SinglePackageSilent],[SinglePackageWithPostAndPre],[SinglePackageWithPostNoPre],[SinglePackageWithPreNoPost].  
classValidated | Denotes whether or not the ring successfully passed the class validation of the deployment data.
deploymentLengthInDays| Ring designation indicating the length of time that the deployment should run.
deploymentStartTime| The 24-hour value of the intended start time.  Example: 00:00 is the default value and representative of midnight.
deploymentEndTime| The 24-hour value of the intended stop time.  Example: 00:00 is the default value and representative of midnight.  null is an acceptable value for Ongoing deployment classes.
downloadImmediately| Indicates whether or not endpoints should begin downloading content as soon as the deployment is created. Consider the size of the audience you are targeting carefully.
deploymentID| The deployment ID of the deployment created by the Toolkit.
deployedOn| The datetime value of the deployment created by the Toolkit.
eussAvailableBeforeStart | Indicates whether or not users should be able to interact with the deployment prior to start time.
operation | The deployment operation that should be leveraged in the deployment. Default value is 'update'.
overrideMaintenanceWindows| Indicates whether or not maintenance windows should be respected by the deployment.  Default value is 'true'.
postNotification | An object describing the notification, if any, an end user will see after a deployment
preNotification | An object describing the notification, if any, an end user will see before a deployment
startDateOffsetInDays| An integer value denoting how much of an offset should be configured from the start time.  For example, one would use the $StartToday switch and a startDateOffsetInDays offset of 0 to start a deployment for the same day.
restart | Indicates whether or not the deployment should restart devices.  Default value is [false].
targetType| Indicates the target apparatus for a deployment.  [computerGroup] is currently the only valid value.
targetCriteria| The Computer Group to be targeted by a given deployment ring.  Default value is [No Computers].
targetCriteriaId| The associated ID of the targetCriteria object.
type| Indicates the type of deployment to be created.  'single' is the only valid value and indicates a deployment with defined beginning and end dates.
useTaniumClientTimeZone| Indicates whether or not the deployment should use the client local time.  Default value is 'true'.

### __JSON Catalog - Subkeys of [postNotification],[preNotification] | Tanium Package Deployments__

Keys|Description
--------------|--------------
allowPostpone | If true, the end user will be notified before the deployment begins
body |(Required if notifyUser is true) The body text of the end user notification
countdownToDeadlineInMinutes | (Required if notifyUser is true) The time in minutes before the end of the postponement period when an end user will be shown a countdown to the forced deployment
notifyUser | If true, the end user will be notified after the deployment completes
postponeDurationInMinutes | (Required if allowPostone is true) The amount of time in minutes the deployment can be postponed
title | (Required if notifyUser is true) The title of the end user notification
userPostponementPeriodInMinutesOne | (Required if allowPostpone is true) Postponement period in minutes that will be available to the end user
userPostponementPeriodInMinutesTwo | (Required if allowPostpone is true) Postponement period in minutes that will be available to the end user
userPostponementPeriodInMinutesThree | (Required if allowPostpone is true) Postponement period in minutes that will be available to the end user

## Reference

### __Directory Overview__
````
root/
├─ core/
│  ├─ catalog/
│  │  ├─ repo/
│  │  │  ├─	ex-OngoingPackageDeploymentSilent/
│  │  │  │	├─ googlellc-chrome-x64.json 
│  │  │  │	├─ igorpavlov-7-zip-x64.json
│  │  │  ├─	ex-OngoingPackageWithPostAndPre/
│  │  │  │	├─ googlellc-chrome-x64.json 
│  │  │  │	├─ igorpavlov-7-zip-x64.json
│  │  │  ├─	ex-OngoingPackageWithPostNoPre/
│  │  │  │	├─ googlellc-chrome-x64.json 
│  │  │  │	├─ igorpavlov-7-zip-x64.json
│  │  │  ├─	ex-OngoingPackageWithPreNoPost/
│  │  │  │	├─ googlellc-chrome-x64.json 
│  │  │  │	├─ igorpavlov-7-zip-x64.json
│  │  │  ├─	ex-SinglePackageSilent/
│  │  │  │	├─ googlellc-chrome-x64.json 
│  │  │  │	├─ igorpavlov-7-zip-x64.json
│  │  │  ├─	ex-SinglePackageWithPostAndPre/
│  │  │  │	├─ googlellc-chrome-x64.json 
│  │  │  │	├─ igorpavlov-7-zip-x64.json
│  │  │  ├─	ex-SinglePackageWithPostNoPre/
│  │  │  │	├─ googlellc-chrome-x64.json 
│  │  │  │	├─ igorpavlov-7-zip-x64.json
│  │  │  ├─	ex-SinglePackageWithPreNoPost/
│  │  │  	├─ googlellc-chrome-x64.json 
│  │  │  	├─ igorpavlov-7-zip-x64.json
│  ├─ config/
│  │  │  ├─ exampleConfig.json
│  ├─ functions/
│  │  ├─ Confirm-DeploymentData.ps1
│  │  ├─ Get-LatestTaniumDeployPackage.ps1
│  │  ├─ Get-PatchTuesday.ps1
│  │  ├─ Get-StartAndEndDates.ps1
│  │  ├─ Get-TaniumDeployPackageCacheStatus.ps1
│  │  ├─ New-CredentialObject.ps1
│  │  ├─ New-Session.ps1
│  │  ├─ Send-HTMLEmail.ps1
│  │  ├─ Set-JSONProperty.ps1
│  │  ├─ Submit-TaniumDeployPackageDeployment
│  │  ├─ Write-Log.ps1
├─ jobqueue/
│  ├─ decommissioned/
│  ├─ hold/
├─ logs/
│  ├─ deploymentautomation.log
│  ├─ deploymentautomation.lo
│  ├─ jobfailures.csv
├─ .gitignore
├─ readme.md

````
### __Directory Structure__

Folder|Description
--------------|--------------
core| Contains the Toolkit core dependencies.
catalog| Contains JSON-based catalog entries for deployment.
repo| Contains JSON-based catalog entries that have not been deployed.
config| Contains JSON-based reference file for environmental targeting configurations.
functions| Contains the Toolkit function dependencies.
jobqueue| Contains JSON-based jobs.
decommissioned| Contains completed JSON-based jobs.
hold| Contains JSON-based jobs that encountered an issue during execution.

### __Included Files__

File|Description
--------------|--------------
Confirm-DeploymentData.ps1 | Constructs a deployment data object from the job object and performs a class validation.
DeploymentAutomationToolkit.ps1 | The controller script that drives the toolkit.
exampleConfig.json| Reference item to be configured for targeting different environments. Rename to config.json once configured appropriately.
Get-LatestTaniumDeployPackage.ps1 | Identifies the highest version of a given piece of software in the Gallery and the highest two versions of the same software that have already been imported into Tanium Deploy.
Get-PatchTuesday.ps1| Function that determines the date of Patch Tuesday for a given month/year.
Get-StartAndEndDates.ps1| Calculates Start and End dates for a given deployment.
Get-TaniumDeployPackageCacheStatus.ps1
googlellc-chrome-x64.json| Example catalog item for the Google LLC Chrome product preconfigured to the class of the folder within which it resides.
igorpavlov-7-zip-x64.json| Example catalog item for the Igor Pavlov 7-zip product preconfigured to the class of the folder within which it resides.
New-CredentialObject.ps1| Function that creates a credential object from locally stored credentials.
New-Session.ps1| Function that creates a session with the desired Tanium environment.
Set-JSONProperty.ps1| Function that updates JSON files.
Write-Log.ps1| Function that creates CMTrace/OneTrace-formatted logs.

### __Screenshots__    

![CMTrace/OneTrace-compatible logging](/core/images/formattedLogs.png)

![Distinct deployment identifiers with GUID reference to associated jobs](/core/images/generatedDeployments.png)

### __Change History__

0.5.1

	* Integrated class-based validation for deployment data prior to making commits via TanREST
	* Added support for Pre/Post Notification options for both single and ongoing deployments
	* Unified configuration settings into a single configuration file 
	* Introduced consideration for multi-platform packages in controller script and mandatory catalog item properties.
	* Split off code from controller script into subfunctions to improve readability and assist debugging
	* Reduced unnecessary logic trees that would always evaluate to $true due to location
	* Miscellaneous readability improvements to controller and subfunctions
	* Aligned most runtime variable object properties to align with Tanium object properties where possible. Some still vary for sake of clarity
	* Reduced utilization of one-off variables for clarity; integrated most of these details in the jobs themselves for posterity/troubleshooting

0.0.1

	* Implement automatic config-driven Tanium session creation
	* Implement basic job processing engine
	* Implement automatic package import
	* Implement verbose, CMtrace-compatible logging
	* Establish predictable tooling structure for relational references to dependencies