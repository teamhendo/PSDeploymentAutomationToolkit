function Confirm-DeploymentData {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true, 
		ValueFromPipeline=$true,
		Position=0)]
		[ValidateNotNull()]
		$job,
		[Parameter(Mandatory=$true, 
		ValueFromPipeline=$true,
		Position=1)]
		[ValidateNotNull()]
		$scriptLogFile    
	)
    
    #Requires -Version 5.0

    switch ($x)
    {
        'value1' {  

        }
        {$_ -in 'A','B','C'} {

        }
        'value3' {

        }
        Default {}
    }

    class OngoingPackageDeploymentSilent 
    {
        [string]$Description =              $null
        [int]$DeployedObjectEditId =        $null
        [boolean]$DownloadImmediately =     $null
        [string]$EndTime =                  $null
        [bool]$EussAvailableBeforeStart =   $null
        [string]$Name =                     $null
        [bool]$OverrideMaintenanceWindows = $null
        [string]$Operation =                $null
        [bool]$Restart =                    $null
        [string]$StartTime =                $null      
        [int]$SoftwarePackageId =           $null
        [hashtable]$Target =                $null
        [string]$Type =                     'ongoing'
        [bool]$UseTaniumClientTimeZone =    $null
    
        # Constructor for validation
        OngoingPackageDeploymentSilent (
            [string]$Description,
            [int]$DeployedObjectEditId,
            [bool]$DownloadImmediately,
            [string]$EndTime,
            [bool]$EussAvailableBeforeStart,
            [string]$Name,
            [bool]$OverrideMaintenanceWindows,
            [string]$Operation,
            [bool]$Restart,
            [string]$StartTime,
            [int]$SoftwarePackageId,
            [hashtable]$Target,
            [string]$Type,
            [bool]$UseTaniumClientTimeZone
        )
        {
            $this.Description =                 $Description
            $this.DeployedObjectEditId =        $DeployedObjectEditId
            $this.DownloadImmediately =         $DownloadImmediately
            $this.EndTime =                     $EndTime
            $this.EussAvailableBeforeStart =    $EussAvailableBeforeStart
            $this.Name =                        $Name
            $this.OverrideMaintenanceWindows =  $OverrideMaintenanceWindows
            $this.Operation =                   $Operation
            $this.Restart =                     $Restart
            $this.StartTime =                   $StartTime
            $this.SoftwarePackageId =           $SoftwarePackageId
            $this.Target =                      $Target
            $this.Type =                        $Type
            $this.UseTaniumClientTimeZone =     $UseTaniumClientTimeZone
        }
    }

    $deploymentData = @{
        description = "Created by Deployment Automation Framework on $currentDate as part of Job $($job.guid)";
        deployedObjectEditId = $job.currentSoftwarePackageEditId;
        downloadImmediately = "$($job.$activeRing.downloadImmediately)";
        endTime = "$stopString";
        eussAvailableBeforeStart = "$($job.$activeRing.eussAvailableBeforeStart)";
        name = -join ("PSDAT - ","$($job.productVendor)",' ',"$($job.productName)",' ',"$($job.currentVersion)",' ',"to $($deploymentTarget.name)",' - ',$job.guid);
        overrideMaintenanceWindows = "$($job.$activeRing.overrideMaintenanceWindows)";
        operation = "$($job.$activeRing.operation)";
        restart = "$($job.$activeRing.restart)";
        startTime = "$startString";       
        softwarePackageId = "$($job.packageid)";
        target= @{
            computerGroupIds= @($($deploymentTarget.id));
            questionGroupIds= @();
        };
        type= "$($job.$activeRing.type)";
        useTaniumClientTimeZone = 'true';
    }

    $validationData = [OngoingPackageDeploymentSilent]::new(
        $deploymentData.description,
        $deploymentData.deployedObjectEditId,                                        
        $deploymentData.downloadImmediately,
        $deploymentData.endTime,
        $deploymentData.eussAvailableBeforeStart,
        $deploymentData.name,
        $deploymentData.overrideMaintenanceWindows,
        $deploymentData.operation,
        $deploymentData.restart,
        $deploymentData.startTime,
        $deploymentData.softwarePackageId,
        $deploymentData.target,
        $deploymentData.type,
        $deploymentData.useTaniumClientTimeZone
    )

}