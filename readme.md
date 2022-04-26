# PowerShell Deployment Automation Toolkit

* Author: Brent Henderson
* Release Date: 04/25/2022
* Version: 0.5.5

## Introduction
### __Toolkit Overview__

The PowerShell Deployment Automation Toolkit provides a way to deliver automated deployments through the Tanium Endpoint Management platform.

### __Features__

This script manages the creation of Tanium Deploy and Tanium Patch deployments and will automatically import Tanium Deploy Gallery packages for the Tanium Endpoint Management platform. The tool currently provides the following functionality:

* Deployment automation capabilities for both Tanium Deploy & Tanium Patch
* Support for multiple environments with minimal administrative overhead
* Predefined templates for every class and every Tanium Gallery package serving the Windows platform
* Automatic API session creation mechanism with manual fallback if $CredentialObject variable is not populated
* Catalog items that support an indefinite number of deployment rings
* Independently configurable deployment rings (Eg, a single Tanium Patch catalog item could have one ring for workstations that overrides maintenance windows and a separate ring for servers that respects maintenance windows).
* Automated Tanium Package Gallery package imports
* PowerShell classes to validate deployment data structures prior to API submission
* Support for Pre/Post Notification options with Single and Ongoing deployments in Tanium Deploy
* Support for Restart Notification options with Single and Ongoing deployments in Tanium Patch
* Support for Patch Tuesday offset configuration within deployment rings
* CMTrace/OneTrace-compatible logging

### __Dependencies__

The TanREST PowerShell module is required and cannot currently be distributed by anyone other than Tanium.  Please contact your Technical Account Manager to acquire and install the latest version of TanREST.

### __License__

PowerShell Deployment Automation Toolkit - Provides a way to deliver automated deployments through the Tanium Endpoint Management platform.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

### __Quick Start__
1. Extract the Toolkit to a convenient location. 
2. Navigate to \DeploymentAutomationToolkit\core\catalog\repo
3. Copy one of the json catalog items to \DeploymentAutomationToolkit\core\catalog. Example: Copy \catalog\ex-SinglePackageWithPostAndPre\googlellc-chrome-x64.json to the \DeploymentAutomationToolkit\core\catalog.
4. Add rings by copying the example rings and incrementing the name by one. Example: To define five rings, ensure that there are defined rings named ring1, ring2, ring3, ring4, and ring5. 
5. Modify non-null key values to your preferences.
5. Execute the script.

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

````
powershell.exe -File 'c:\pathToFile\DeploymentAutomationToolkit.ps1' -Environment 'Alt' -QuickTest $true -StartToday $true -CredentialObject (Get-Credential)
````

### __Script Parameters__

Parameters|Description
--------------|--------------
CredentialObject (Optional)| Allows the user to establish a SecureString credential object prior to invocation of the tool.  If absent, the user will be prompted upon initialization.
DecommOnCompletion (Optional)| Designates whether or not jobs should be decommissioned once all rings are deployed; defaults to $true. If set to $false, jobs will remain in the root/jobqueue/ directory and no subsequent jobs for that software will proceed until the job is manually copied to the root/jobqueue/decommissioned/ directory.
Environment (Optional)| Designates the operating environment for the script to execute upon.  Jobs from multiple environments can coexist so back-to-back executions from multiple environments will function appropriately.  The default value is 'Alt'.
QuickTest (Optional)| Designates whether or not an abbreviated run should be facilitated; defaults to $false as a precaution against initialization issues that can come from processing too many jobs in quick succession.
StartToday| Designates whether or not the startDateOffsetInDays value in catalog items will offset relative to the runtime date or the next Patch Tuesday; defaults to $false.

### __JSON Catalog Keys | Tanium Patch & Tanium Deploy Package Deployments__

Note: Any null values in the example files under /core/catalog/repo denote values that will be established at runtime by the toolkit itself.  <b><u>Users should not modify or remove null values.</u></b> Key definitions for Patch and Deploy have been consolidated; keys that only apply to one or the other will be denoted by [Deploy] or [Patch].

Keys|Description
--------------|--------------
allRingsDeployed| Indicates whether or not all defined rings within the job have been deployed.
architecture| Architecture of the package to be deployed. Valid entries are [x64],[x86],[any].
contentAcquired| Indicates whether or not the content for the package has been cached. Applies to [Deploy] catalog items.
currentVersion| Reflects current software version for a given package that is available. Applies to [Deploy] catalog items.
currentSoftwarePackageEditId| The current software package object version. Applies to [Deploy] catalog items.
deployedObjectEditId| Functionally identical to currentSoftwarePackageEditId (current is used in package metadata; deployedObjectEditId is used to create deployments). Applies to [Deploy] catalog items.
frameworkCatalogName| The name of the source catalog item that the job was created to address.  Must be the exact name; see examples.
guid| The unique GUID assigned to the job at runtime.
holdReason| The reason, if any, why a package was placed in a hold state.
jobFileLocation| The current location of the job file.  
jobStatus| The current status of the job.
lastModified| Indicates the last time the Toolkit modified a given job file.
packageCacheLoop| An integer value indicating how many loops the package cache logic should take.  Each loop is 10 seconds so a value of 30 would allow for a maximum of 5 minutes before the job was placed in a hold state. Applies to [Deploy] catalog items.
platform| The platform that the job is targeted toward. Valid values are [windows] or [macos]. Applies to [Deploy] catalog items.
previousSoftwarePackageId| The previous package ID of the software that is being deployed by a given job. This property was previously named previousPackageID but amended to align more closely with Tanium object properties. Applies to [Deploy] catalog items.
productName| The product name of the software being deployed by a given job.
productVendor| The product vendor of the software being deployed by a given job.
ring#| Deployment rings (ring1, ring2, etc.) are objects with their own subkeys that define the pertinent details of a deployment.  The subkeys are detailed below.
softwarePackageId| The current package ID of the package being deployed by a given job. This property was previously named packageId but amended to align with Tanium object properties.
source| The source property denotes the source from which the package content will be acquired. Valid values are [deployGallery] and [taniumPatch].
type| The type key denotes what is being deployed by the job. Valid values are [package] and [patch].

### __JSON Catalog - Subkeys of ring# | Tanium Patch & Package Deployments__
<b><u>Reminder: Users should not modify or remove null values.</u></b>

Keys|Description
--------------|--------------
class | Denotes the class of the ring that is being deployed.  Valid values are [OngoingPackageDeploymentSilent],[OngoingPackageWithPostAndPre],[OngoingPackageWithPostNoPre],[OngoingPackageWithPreNoPost],[SinglePackageSilent],[SinglePackageWithPostAndPre],[SinglePackageWithPostNoPre],[SinglePackageWithPreNoPost], [SinglePatchlistWithPost].  
classValidated | Denotes whether or not the ring successfully passed the class validation of the deployment data.
deploymentLengthInDays| Ring designation indicating the length of time that the deployment should run.
deploymentStartTime| The 24-hour value of the intended start time.  Example: 00:00 is the default value and representative of midnight.
deploymentEndTime| The 24-hour value of the intended stop time.  Example: 00:00 is the default value and representative of midnight.  null is an acceptable value for Ongoing deployment classes.
deploymentStartTimeString| null key that the Toolkit will use to store the formatted start time value derived at runtime.
deploymentEndTimeString| null key that the Toolkit will use to store the formatted end time value derived at runtime.
description| null key that the Toolkit will use to tattoo the deployment with key information such as the job GUID.
distributeOverTimeMinutes| Number of minutes to distribute the deployment across. Example: 120 would distribute the deployment over two hours.
downloadImmediately| Indicates whether or not endpoints should begin downloading content as soon as the deployment is created. Consider the size of the audience you are targeting carefully.
deploymentID| null key that the Toolkit will use to store the deployment ID of a successful deployment.
deployedOn| The datetime value of the deployment created by the Toolkit.
endTime| null key that the Toolkit will use to store the ending time of the deployment for [Single] deployments.
eussAvailableBeforeStart | Indicates whether or not users should be able to interact with the deployment prior to start time.
operation | The deployment operation that should be leveraged in the deployment. The default value for [deployGallery] jobs is [update]; the default value for [taniumPatch] jobs is [install].
overrideMaintenanceWindows| Indicates whether or not maintenance windows should be respected by the deployment. The default value is [false].
postNotification | The notification that an end user will see after a Tanium Deploy deployment. Applies to [Deploy] catalog items.
preNotification | The notification that an end user will see before a Tanium Deploy deployment. Applies to [Deploy] catalog items.
restart | Indicates whether or not the deployment should restart devices.  The default value is [false]. Valid values are [true] and [false].
restartClientNotification| The notfication that an end user will see after a Patch deployment. Applies to [Patch] catalog items.
startDateOffsetInDays| An integer value denoting how much of an offset should be configured from the start time.  For example, one would use the $StartToday switch and a startDateOffsetInDays offset of 0 to start a deployment for the same day.
targetedComputerGroupIds| null key that the Toolkit will use to store the ID of the Computer Group defined in the targetCriteria key. Applies to [Patch] catalog items.
targetType| Indicates the target apparatus for a deployment.  [computerGroup] is currently the only valid value.
targetCriteria| The Computer Group to be targeted by a given deployment ring.  Default value is [No Computers].
targetCriteriaId| null key that the Toolkit will use to store associated ID of the targetCriteria object. Applies to [Deploy] catalog items.
type| Indicates the type of deployment to be created.  'single' is the only valid value and indicates a deployment with defined beginning and end dates.
useTaniumClientTimeZone| Indicates whether or not the deployment should use the client local time.  Default value is [true]. Valid values are [true] and [false].

### __JSON Catalog - Subkeys of [postNotification],[preNotification] | Tanium Package Deployments__
<b><u>Reminder: Users should not modify or remove null values.</u></b>
Keys|Description
--------------|--------------
allowPostpone | Determines whether end user will be notified before the deployment begins. Valid values are [true] and [false].
body |(Required if notifyUser is true) The body text of the end user notification.
countdownToDeadlineInMinutes | (Required if notifyUser is true) The time in minutes before the end of the postponement period when an end user will be shown a countdown to the forced deployment
notifyUser | If true, the end user will be notified after the deployment completes
postponeDurationInMinutes | (Required if allowPostone is true) The amount of time in minutes the deployment can be postponed
title | (Required if notifyUser is true) The title of the end user notification
userPostponementPeriodInMinutesOne | (Required if allowPostpone is true) Postponement period in minutes that will be available to the end user
userPostponementPeriodInMinutesTwo | (Required if allowPostpone is true) Postponement period in minutes that will be available to the end user
userPostponementPeriodInMinutesThree | (Required if allowPostpone is true) Postponement period in minutes that will be available to the end user

### __JSON Catalog - Subkeys of [restartClientNotification] | Tanium Patch Deployments__

Keys|Description
--------------|--------------
allowPostpone| Determines whether end user will be notified before the restart occurs. Valid values are [true] and [false].
body| The body text of the end user notification.
countdownToDeadlineInMinutes|The time in minutes before the end of the postponement period.
gentleNotificationDurationInMinutes| ??? Cannot find reference to this key in API documentation.  
icon| The title icon for the end user notification.
postponeDurationInMinutes| The amount of time in minutes the deployment can be postponed.
title| The title of the end user notification.
userPostponementPeriodInMinutesOne|Postponement period in minutes that will be available to the end user.
userPostponementPeriodInMinutesTwo|Postponement period in minutes that will be available to the end user.
userPostponementPeriodInMinutesThree|Postponement period in minutes that will be available to the end user.
## Reference

### __Directory Overview__
````
root/
├─ core/
│  ├─ catalog/
│  │  ├─ repo/
│  │  │  ├─	ex-OngoingPackageDeploymentSilent/
│  │  │  │	├─ templates
│  │  │  ├─	ex-OngoingPackageWithPostAndPre/
│  │  │  │	├─ templates
│  │  │  ├─	ex-OngoingPackageWithPostNoPre/
│  │  │  │	├─ templates
│  │  │  ├─	ex-OngoingPackageWithPreNoPost/
│  │  │  │	├─ templates
│  │  │  ├─	ex-SinglePackageSilent/
│  │  │  │	├─ templates
│  │  │  ├─	ex-SinglePackageWithPostAndPre/
│  │  │  │	├─ templates
│  │  │  ├─	ex-SinglePackageWithPostNoPre/
│  │  │  │	├─ templates
│  │  │  ├─	ex-SinglePackageWithPreNoPost/
│  │  │  │	├─ templates
│  │  │  ├─	ex-SinglePatchlistWithPost/
│  │  │  │	├─ windows-with-notification.json 
│  ├─ config/
│  ├─ functions/
│  │  ├─ Confirm-DeploymentData.ps1
│  │  ├─ Get-DAAddress.ps1
│  │  ├─ Get-DACredentials.ps1
│  │  ├─ Get-LatestTaniumDeployPackage.ps1
│  │  ├─ Get-PatchTuesday.ps1
│  │  ├─ Get-StartAndEndDates.ps1
│  │  ├─ Get-TaniumDeployPackageCacheStatus.ps1
│  │  ├─ New-DASession.ps1
│  │  ├─ Set-JSONProperty.ps1
│  │  ├─ Start-GalleryPackageDeploymentProcessing.ps1
│  │  ├─ Start-PatchDeploymentProcessing.ps1
│  │  ├─ Submit-TaniumDeployPackageDeployment.ps1
│  │  ├─ Submit-TaniumPatchDeployment.ps1
│  │  ├─ Write-Log.ps1
├─ jobqueue/
│  ├─ decommissioned/
│  ├─ hold/
├─ logs/
│  ├─ deploymentautomation.log
├─ .gitignore
├─ DeploymentAutomationToolkit.ps1
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
Confirm-DAAddress.ps1 | Gathers Tanium API URI information from user.
Confirm-DACredentials.ps1 | Gathers Tanium API user credentials if $CredentialObject is not passed upon invocation. Credentials are not stored by the Toolkit.
DeploymentAutomationToolkit.ps1 | The controller script that drives the Toolkit.
Get-LatestTaniumDeployPackage.ps1 | Identifies the latest version of a given piece of software in the Deploy Package Gallery and imports that package if it has a higher version than what is already present in the Deploy catalog.
Get-PatchTuesday.ps1| Function that determines the date of Patch Tuesday for a given month/year.
Get-StartAndEndDates.ps1| Calculates Start and End dates for a given deployment.
Get-TaniumDeployPackageCacheStatus.ps1 | Monitors the import process from the Deploy Package Gallery.
googlellc-chrome-x64.json| Example catalog item for the Google LLC Chrome product preconfigured to the class of the folder within which it resides.
igorpavlov-7-zip-x64.json| Example catalog item for the Igor Pavlov 7-zip product preconfigured to the class of the folder within which it resides.
New-DASession.ps1| Function that gathers input from user and creates a session with the desired Tanium environment.
Set-JSONProperty.ps1| Function that updates JSON files.
Start-GalleryPackageDeploymentProcessing.ps1| Processes Tanium Deploy catalog job objects by iterating through defined rings.
Start-PatchDeploymentProcessing.ps1| Processes Tanium Patch catalog job objects by iterating through defined rings.
Submit-TaniumDeployPackageDeployment.ps1| Submits Tanium Deploy job rings to the Tanium API.
Submit-TaniumPatchDeployment.ps1|Submits Tanium Patch job rings to the Tanium API.
windows-with-notification.json |Example catalog item for Microsoft Windows patch deployments preconfigured to the class of the folder within which it resides.
Write-Log.ps1| Function that creates CMTrace/OneTrace-formatted logs.

### __Screenshots__    

![CMTrace/OneTrace-compatible logging](/core/images/formattedLogs.png)

![Distinct deployment identifiers with GUID reference to associated jobs](/core/images/generatedDeployments.png)

![Distinct deployment identifiers with GUID reference to associated jobs](/core/images/generatedDeployments.png)

![Windows Update catalog item processing](/core/images/windowsUpdates1.png)

![Windows Update catalog item result](/core/images/windowsUpdates2.png)

### __Change History__
0.5.5

	* Added support for Tanium Patch to allow 1st-party patching through Deployment Automation Toolkit
	* Addressed bug in Get-LatestTaniumDeployPackage function caused by absence of [version] type accelerator
	* Amended Confirm-DeploymentData with Tanium Patch class structure validation
	* Removed support for credential storage. Will revisit when the project is further along.

	* Known Issues
	* Individually stored functions are unwieldy; likely to be consolidated into a Main script later.

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