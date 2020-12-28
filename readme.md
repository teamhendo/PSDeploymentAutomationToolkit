# PowerShell Deployment Automation Toolkit

* Author: Brent Henderson
* Release Date: 12/28/2020
* Version: 0.0.1

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
powershell.exe -File '\\pathToFile\DeploymentAutomationToolkit.ps1' -Environment < Alt | DEV | QA | PROD >
````

````
powershell.exe -File 'c:\pathToFile\DeploymentAutomationToolkit.ps1' -Environment 'Alt' -QuickTest $true -StartToday $true
````

### __Quick Start__

1. Configure reference file(s) for environment(s) under scriptRoot\core\config
2. Encrypted credentials may be stored in scriptRoot\core\config as tanium__ENV__Cred.txt (Not Recommended for Production, Example 1 below)
3. Configure json catalog files under scriptRoot\core\catalog\repo
4. Promote configured json catalog items to scriptRoot\core\catalog
5. Call script with desired environmental target

Example 1: The ConvertFrom-SecureString cmdlet converts a secure string into an encrypted standard string.  

````PowerShell
(Get-Credential).password | ConvertFrom-SecureString | Out-File "$scriptDirectory\core\config\tanium__ENV__Cred.txt"
````

### __Script Parameters__

Parameters|Description
--------------|--------------
DecommOnCompletion| Designates whether or not jobs should be decommissioned once all rings are deployed; defaults to $true. If set to $false, jobs will remain in the root/jobqueue/ directory and no subsequent jobs for that software will proceed until the job is manually copied to the root/jobqueue/decommissioned/ directory.
Environment| Designates the operating environment for the script to execute upon.  Jobs from multiple environments can coexist so back-to-back executions from multiple environments will function appropriately.
QuickTest| Designates whether or not an abbreviated run should be facilitated; defaults to $false as a precaution.
StartToday| Designates whether or not the startDateOffsetInDays value in catalog items will offset relative to the runtime date or the next Patch Tuesday; defaults to $false.

### __JSON Catalog Keys | Tanium Package Deployments__

Parameters|Description
--------------|--------------
allRingsDeployed| Indicates whether or not all defined rings within the job have been deployed.
architecture| The architecture of the package to be deployed. Value values are [x64,x86,any]
contentAcquired| Indicates whether or not the content for the package has been cached.
currentVersion| The current software version for a given package that is available.
currentSoftwarePackageEditId| The current software package object version.
frameworkCatalogName| The name of the source catalog item that the job was derived from.
guid| The unique GUID assigned to the job at runtime.
jobFileLocation| The current location of the job file.    
jobStatus| The current status of the job.
lastVersion| The previous software version for a given package that is being managed by the job.
lastModified| Indicates the last time the Toolkit modified a given job file.
packageCacheLoop| An integer value indicating how many loops the package cache logic should take.  Each loop is 10 seconds so a value of 30 would allow for a maximum of 5 minutes before the job was placed in a hold state.
packageID| The current package ID of the package being deployed by a given job.
previousPackageID| The previous package ID of the software that is being deployed by a given job.
productName| The product name of the software being deployed by a given job.
productVendor| The product vendor of the software being deployed by a given job.
deploymentLengthInDays| Ring designation indicating the length of time that the deployment should run.
deploymentStopTime| The 24-hour value of the intended stop time.  Example: 00:00 is the default value and representative of midnight.
deploymentStartTime| The 24-hour value of the intended start time.  Example: 00:00 is the default value and representative of midnight.
downloadImmediately| Indicates whether or not endpoints should begin downloading content as soon as the deployment is created. Consider the size of the audience you are targeting carefully.
deploymentID| The deployment ID of the deployment created by the Toolkit.
deployedOn| The datetime value of the deployment created by the Toolkit.
eussAvailableBeforeStart | Indicates whether or not users should be able to interact with the deployment prior to start time.
operation | The deployment operation that should be leveraged in the deployment. Default value is 'update'.
overrideMaintenanceWindows| Indicates whether or not maintenance windows should be respected by the deployment.  Default value is 'true'.
startDateOffsetInDays| An integer value denoting how much of an offset should be configured from the start time.  For example, one would use the $StartToday switch and a startDateOffsetInDays offset of 0 to start a deployment for the same day.
restart | Indicates whether or not the deployment should restart devices.  Default value is 'false'.
targetType| Indicates the target apparatus for a deployment.  'computerGroup' is currently the only valid value.
targetCriteria| The Computer Group to be targeted by a given deployment ring.  Default value is 'No Computers'.
type| Indicates the type of deployment to be created.  'single' is the only valid value and indicates a deployment with defined beginning and end dates.
useTaniumClientTimeZone| Indicates whether or not the deployment should use the client local time.  Default value is 'true'.

## Reference

### __Directory Overview__
````
root/
├─ core/
│  ├─ catalog/
│  │  ├─ repo/
│  │  │  ├─ googlellc-chrome-x64.json 
│  │  │  ├─ igorpavlov-7-zip-x64.json
│  ├─ config/
│  │  │  ├─ alt-reference.json
│  │  │  ├─ dev-reference.json
│  │  │  ├─ prod-reference.json
│  │  │  ├─ qa-reference.json
│  ├─ functions/
│  │  ├─ Get-PatchTuesday.ps1
│  │  ├─ New-CredentialObject.ps1
│  │  ├─ New-Session.ps1
│  │  ├─ Send-HTMLEmail.ps1
│  │  ├─ Set-JSONProperty.ps1
│  │  ├─ Write-Log.ps1
├─ jobqueue/
│  ├─ decommissioned/
│  ├─ hold/
├─ logs/
├─ .gitignore
├─ readme.md

````
### __Directory Structure__

Folder|Description
--------------|--------------
core| Contains the Toolkit core dependencies.
catalog| Contains JSON-based catalog entries for deployment.
repo| Contains JSON-based catalog entries that have not been deployed.
config| Contains JSON-based reference files for environmental targeting configurations.
functions| Contains the Toolkit function dependencies.
jobqueue| Contains JSON-based jobs.
decommissioned| Contains completed JSON-based jobs.
hold| Contains JSON-based jobs that encountered an issue during execution.

### __File Structure__

File|Description
--------------|--------------
googlellc-chrome-x64.json| Example catalog item for the Google LLC Chrome product.
igorpavlov-7-zip-x64.json| Example catalog item for the Igor Pavlov 7-zip product.
dev-reference.json| Reference item to be configured for targeting "DEV" environments.
prod-reference.json| Reference item to be configured for targeting "PROD" environments.
qa-reference.json| Reference item to be configured for targeting "QA" environments.
Get-PatchTuesday.ps1| Function that determines the date of Patch Tuesday for a given month/year.
New-CredentialObject.ps1| Function that creates a credential object from locally stored credentials.
New-Session.ps1| Function that creates a session with the desired Tanium environment.
[Send-HTMLEmail](https://stackoverflow.com/users/9062681/theironrose)| Function that translates an input object to an HTML-formatted email.  
Set-JSONProperty.ps1| Function that updates JSON files.
Write-Log.ps1| Function that creates CMTrace/OneTrace-formatted logs.

### __Upcoming Functionality__
    * Catalog-driven Tanium Patch deployments
    * Sub-function for building more dynamic deployments with an understanding of parameter set grouping
    * Transition to direct API calls to reduce dependencies and error opportunities.

### __Screenshots__    

![CMTrace/OneTrace-compatible logging](/core/images/formattedLogs.png)

![Distinct deployment identifiers with GUID reference to associated jobs](/core/images/generatedDeployments.png)