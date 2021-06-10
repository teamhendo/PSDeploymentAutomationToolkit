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

    Begin {
        [int]$ringCount = $($job | Get-Member | Where-Object {$_.name -like "ring*"}).count
        [int]$ringLoop = 1
        
        #Validated

        class OngoingPackageDeploymentSilent {
            [ValidateNotNullOrEmpty()][string]$Description
            [ValidateNotNullOrEmpty()][int]$DeployedObjectEditId
            [ValidateNotNullOrEmpty()][boolean]$DownloadImmediately
            [ValidateNotNullOrEmpty()][bool]$EussAvailableBeforeStart
            [ValidateNotNullOrEmpty()][string]$Name
            [ValidateNotNullOrEmpty()][bool]$OverrideMaintenanceWindows
            [ValidateNotNullOrEmpty()][string]$Operation
            [ValidateNotNullOrEmpty()][bool]$Restart
            [ValidateNotNullOrEmpty()][string]$StartTime
            [ValidateNotNullOrEmpty()][int]$SoftwarePackageId
            [ValidateNotNullOrEmpty()][hashtable]$Target
            [ValidateNotNullOrEmpty()][string]$Type
            [ValidateNotNullOrEmpty()][bool]$UseTaniumClientTimeZone
            
            # Constructor for validation
            OngoingPackageDeploymentSilent (
            [string]$Description,
            [int]$DeployedObjectEditId,
            [bool]$DownloadImmediately,
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

        # Validated

        class OngoingPackageWithPostAndPre {
            [ValidateNotNullOrEmpty()][string]$Description
            [ValidateNotNullOrEmpty()][int]$DeployedObjectEditId
            [ValidateNotNullOrEmpty()][boolean]$DownloadImmediately
            [ValidateNotNullOrEmpty()][bool]$EussAvailableBeforeStart
            [ValidateNotNullOrEmpty()][string]$Name
            [ValidateNotNullOrEmpty()][bool]$OverrideMaintenanceWindows
            [ValidateNotNullOrEmpty()][string]$Operation
            [ValidateNotNullOrEmpty()][hashtable]$PostNotification
            [ValidateNotNullOrEmpty()][hashtable]$PreNotification
            [ValidateNotNullOrEmpty()][bool]$Restart
            [ValidateNotNullOrEmpty()][string]$StartTime
            [ValidateNotNullOrEmpty()][int]$SoftwarePackageId
            [ValidateNotNullOrEmpty()][hashtable]$Target
            [ValidateNotNullOrEmpty()][string]$Type
            [ValidateNotNullOrEmpty()][bool]$UseTaniumClientTimeZone
            
            # Constructor for validation
            OngoingPackageWithPostAndPre (
                 [string]$Description,
                 [int]$DeployedObjectEditId,
                 [bool]$DownloadImmediately,
                 [bool]$EussAvailableBeforeStart,
                 [string]$Name,
                 [bool]$OverrideMaintenanceWindows,
                 [string]$Operation,
                 [hashtable]$PostNotification,
                 [hashtable]$PreNotification,
                 [bool]$Restart,
                 [string]$StartTime,
                 [int]$SoftwarePackageId,
                 [hashtable]$Target,
                 [string]$Type,
                 [bool]$UseTaniumClientTimeZone
            )
            {
                 $this.Description                   = $Description
                 $this.DeployedObjectEditId          = $DeployedObjectEditId
                 $this.DownloadImmediately           = $DownloadImmediately
                 $this.EussAvailableBeforeStart      = $EussAvailableBeforeStart
                 $this.Name                          = $Name
                 $this.OverrideMaintenanceWindows    = $OverrideMaintenanceWindows
                 $this.Operation                     = $Operation
                 $this.PostNotification              = $PostNotification
                 $this.PreNotification               = $PreNotification
                 $this.Restart                       = $Restart
                 $this.StartTime                     = $StartTime
                 $this.SoftwarePackageId             = $SoftwarePackageId
                 $this.Target                        = $Target
                 $this.Type                          = $Type
                 $this.UseTaniumClientTimeZone       = $UseTaniumClientTimeZone
            }
        }
        # Validated
        
        class OngoingPackageWithPostNoPre {
            [ValidateNotNullOrEmpty()][string]$Description
            [ValidateNotNullOrEmpty()][int]$DeployedObjectEditId
            [ValidateNotNullOrEmpty()][boolean]$DownloadImmediately
            [ValidateNotNullOrEmpty()][bool]$EussAvailableBeforeStart
            [ValidateNotNullOrEmpty()][string]$Name
            [ValidateNotNullOrEmpty()][bool]$OverrideMaintenanceWindows
            [ValidateNotNullOrEmpty()][string]$Operation
            [ValidateNotNullOrEmpty()][hashtable]$PostNotification
            [ValidateNotNullOrEmpty()][bool]$Restart
            [ValidateNotNullOrEmpty()][string]$StartTime
            [ValidateNotNullOrEmpty()][int]$SoftwarePackageId
            [ValidateNotNullOrEmpty()][hashtable]$Target
            [ValidateNotNullOrEmpty()][string]$Type
            [ValidateNotNullOrEmpty()][bool]$UseTaniumClientTimeZone
            
            # Constructor for validation
            OngoingPackageWithPostNoPre (
                 [string]$Description,
                 [int]$DeployedObjectEditId,
                 [bool]$DownloadImmediately,
                 [bool]$EussAvailableBeforeStart,
                 [string]$Name,
                 [bool]$OverrideMaintenanceWindows,
                 [string]$Operation,
                 [hashtable]$PostNotification,
                 [bool]$Restart,
                 [string]$StartTime,
                 [int]$SoftwarePackageId,
                 [hashtable]$Target,
                 [string]$Type,
                 [bool]$UseTaniumClientTimeZone
            )
            {
                 $this.Description                   = $Description
                 $this.DeployedObjectEditId          = $DeployedObjectEditId
                 $this.DownloadImmediately           = $DownloadImmediately
                 $this.EussAvailableBeforeStart      = $EussAvailableBeforeStart
                 $this.Name                          = $Name
                 $this.OverrideMaintenanceWindows    = $OverrideMaintenanceWindows
                 $this.Operation                     = $Operation
                 $this.PostNotification              = $PostNotification
                 $this.Restart                       = $Restart
                 $this.StartTime                     = $StartTime
                 $this.SoftwarePackageId             = $SoftwarePackageId
                 $this.Target                        = $Target
                 $this.Type                          = $Type
                 $this.UseTaniumClientTimeZone       = $UseTaniumClientTimeZone
            }
        }

        # Validated

        class OngoingPackageWithPreNoPost {
            [ValidateNotNullOrEmpty()][string]$Description
            [ValidateNotNullOrEmpty()][int]$DeployedObjectEditId
            [ValidateNotNullOrEmpty()][boolean]$DownloadImmediately
            [ValidateNotNullOrEmpty()][bool]$EussAvailableBeforeStart
            [ValidateNotNullOrEmpty()][string]$Name
            [ValidateNotNullOrEmpty()][bool]$OverrideMaintenanceWindows
            [ValidateNotNullOrEmpty()][string]$Operation
            [ValidateNotNullOrEmpty()][string]$PreNotification
            [ValidateNotNullOrEmpty()][bool]$Restart
            [ValidateNotNullOrEmpty()][string]$StartTime
            [ValidateNotNullOrEmpty()][int]$SoftwarePackageId
            [ValidateNotNullOrEmpty()][hashtable]$Target
            [ValidateNotNullOrEmpty()][string]$Type
            [ValidateNotNullOrEmpty()][bool]$UseTaniumClientTimeZone
            
            # Constructor for validation
            OngoingPackageWithPreNoPost (
            [string]$Description,
            [int]$DeployedObjectEditId,
            [bool]$DownloadImmediately,
            [bool]$EussAvailableBeforeStart,
            [string]$Name,
            [bool]$OverrideMaintenanceWindows,
            [string]$Operation,
            [hashtable]$PreNotification,
            [bool]$Restart,
            [string]$StartTime,
            [int]$SoftwarePackageId,
            [hashtable]$Target,
            [string]$Type,
            [bool]$UseTaniumClientTimeZone
            )
            {
            $this.Description                   = $Description
            $this.DeployedObjectEditId          = $DeployedObjectEditId
            $this.DownloadImmediately           = $DownloadImmediately
            $this.EussAvailableBeforeStart      = $EussAvailableBeforeStart
            $this.Name                          = $Name
            $this.OverrideMaintenanceWindows    = $OverrideMaintenanceWindows
            $this.Operation                     = $Operation
            $this.PreNotification               = $PreNotification
            $this.Restart                       = $Restart
            $this.StartTime                     = $StartTime
            $this.SoftwarePackageId             = $SoftwarePackageId
            $this.Target                        = $Target
            $this.Type                          = $Type
            $this.UseTaniumClientTimeZone       = $UseTaniumClientTimeZone
            }
        }

        # Validated

        class SinglePackageSilent {
            [ValidateNotNullOrEmpty()][string]$Description
            [ValidateNotNullOrEmpty()][int]$DeployedObjectEditId
            [ValidateNotNullOrEmpty()][boolean]$DownloadImmediately
            [ValidateNotNullOrEmpty()][bool]$EussAvailableBeforeStart
            [ValidateNotNullOrEmpty()][string]$Name
            [ValidateNotNullOrEmpty()][bool]$OverrideMaintenanceWindows
            [ValidateNotNullOrEmpty()][string]$Operation
            [ValidateNotNullOrEmpty()][bool]$Restart
            [ValidateNotNullOrEmpty()][string]$StartTime
            [ValidateNotNullOrEmpty()][string]$EndTime
            [ValidateNotNullOrEmpty()][int]$SoftwarePackageId
            [ValidateNotNullOrEmpty()][hashtable]$Target
            [ValidateNotNullOrEmpty()][string]$Type
            [ValidateNotNullOrEmpty()][bool]$UseTaniumClientTimeZone
            
            # Constructor for validation
            SinglePackageSilent (
            [string]$Description,
            [int]$DeployedObjectEditId,
            [bool]$DownloadImmediately,
            [bool]$EussAvailableBeforeStart,
            [string]$Name,
            [bool]$OverrideMaintenanceWindows,
            [string]$Operation,
            [bool]$Restart,
            [string]$StartTime,
            [string]$EndTime,
            [int]$SoftwarePackageId,
            [hashtable]$Target,
            [string]$Type,
            [bool]$UseTaniumClientTimeZone
            )
            {
            $this.Description =                 $Description
            $this.DeployedObjectEditId =        $DeployedObjectEditId
            $this.DownloadImmediately =         $DownloadImmediately
            $this.EussAvailableBeforeStart =    $EussAvailableBeforeStart
            $this.Name =                        $Name
            $this.OverrideMaintenanceWindows =  $OverrideMaintenanceWindows
            $this.Operation =                   $Operation
            $this.Restart =                     $Restart
            $this.StartTime =                   $StartTime
            $this.EndTime =                     $EndTime
            $this.SoftwarePackageId =           $SoftwarePackageId
            $this.Target =                      $Target
            $this.Type =                        $Type
            $this.UseTaniumClientTimeZone =     $UseTaniumClientTimeZone
            }
        }

        # Validated 
        class SinglePackageWithPostAndPre {
            [ValidateNotNullOrEmpty()][string]$Description
            [ValidateNotNullOrEmpty()][int]$DeployedObjectEditId
            [ValidateNotNullOrEmpty()][boolean]$DownloadImmediately
            [ValidateNotNullOrEmpty()][string]$EndTime
            [ValidateNotNullOrEmpty()][bool]$EussAvailableBeforeStart
            [ValidateNotNullOrEmpty()][string]$Name
            [ValidateNotNullOrEmpty()][bool]$OverrideMaintenanceWindows
            [ValidateNotNullOrEmpty()][string]$Operation
            [ValidateNotNullOrEmpty()][hashtable]$PostNotification
            [ValidateNotNullOrEmpty()][hashtable]$PreNotification
            [ValidateNotNullOrEmpty()][bool]$Restart
            [ValidateNotNullOrEmpty()][string]$StartTime
            [ValidateNotNullOrEmpty()][int]$SoftwarePackageId
            [ValidateNotNullOrEmpty()][hashtable]$Target
            [ValidateNotNullOrEmpty()][string]$Type
            [ValidateNotNullOrEmpty()][bool]$UseTaniumClientTimeZone
       
            # Constructor for validation
            SinglePackageWithPostAndPre (
                 [string]$Description,
                 [int]$DeployedObjectEditId,
                 [bool]$DownloadImmediately,
                 [string]$EndTime,
                 [bool]$EussAvailableBeforeStart,
                 [string]$Name,
                 [bool]$OverrideMaintenanceWindows,
                 [string]$Operation,
                 [hashtable]$PostNotification,
                 [hashtable]$PreNotification,
                 [bool]$Restart,
                 [string]$StartTime,
                 [int]$SoftwarePackageId,
                 [hashtable]$Target,
                 [string]$Type,
                 [bool]$UseTaniumClientTimeZone
            )
            {
                 $this.Description                   = $Description
                 $this.DeployedObjectEditId          = $DeployedObjectEditId
                 $this.DownloadImmediately           = $DownloadImmediately
                 $this.EndTime                       = $EndTime
                 $this.EussAvailableBeforeStart      = $EussAvailableBeforeStart
                 $this.Name                          = $Name
                 $this.OverrideMaintenanceWindows    = $OverrideMaintenanceWindows
                 $this.Operation                     = $Operation
                 $this.PostNotification              = $PostNotification
                 $this.PreNotification               = $PreNotification
                 $this.Restart                       = $Restart
                 $this.StartTime                     = $StartTime
                 $this.SoftwarePackageId             = $SoftwarePackageId
                 $this.Target                        = $Target
                 $this.Type                          = $Type
                 $this.UseTaniumClientTimeZone       = $UseTaniumClientTimeZone
            }
        }

        # Validated

        class SinglePackageWithPostNoPre {
            [ValidateNotNullOrEmpty()][string]$Description
            [ValidateNotNullOrEmpty()][int]$DeployedObjectEditId
            [ValidateNotNullOrEmpty()][boolean]$DownloadImmediately
            [ValidateNotNullOrEmpty()][string]$EndTime
            [ValidateNotNullOrEmpty()][bool]$EussAvailableBeforeStart
            [ValidateNotNullOrEmpty()][string]$Name
            [ValidateNotNullOrEmpty()][bool]$OverrideMaintenanceWindows
            [ValidateNotNullOrEmpty()][string]$Operation
            [ValidateNotNullOrEmpty()][hashtable]$PostNotification
            [ValidateNotNullOrEmpty()][bool]$Restart
            [ValidateNotNullOrEmpty()][string]$StartTime
            [ValidateNotNullOrEmpty()][int]$SoftwarePackageId
            [ValidateNotNullOrEmpty()][hashtable]$Target
            [ValidateNotNullOrEmpty()][string]$Type
            [ValidateNotNullOrEmpty()][bool]$UseTaniumClientTimeZone
       
            # Constructor for validation
            SinglePackageWithPostNoPre (
                 [string]$Description,
                 [int]$DeployedObjectEditId,
                 [bool]$DownloadImmediately,
                 [string]$EndTime,
                 [bool]$EussAvailableBeforeStart,
                 [string]$Name,
                 [bool]$OverrideMaintenanceWindows,
                 [string]$Operation,
                 [hashtable]$PostNotification,
                 [bool]$Restart,
                 [string]$StartTime,
                 [int]$SoftwarePackageId,
                 [hashtable]$Target,
                 [string]$Type,
                 [bool]$UseTaniumClientTimeZone
            )
            {
                 $this.Description                   = $Description
                 $this.DeployedObjectEditId          = $DeployedObjectEditId
                 $this.DownloadImmediately           = $DownloadImmediately
                 $this.EndTime                       = $EndTime
                 $this.EussAvailableBeforeStart      = $EussAvailableBeforeStart
                 $this.Name                          = $Name
                 $this.OverrideMaintenanceWindows    = $OverrideMaintenanceWindows
                 $this.Operation                     = $Operation
                 $this.PostNotification              = $PostNotification
                 $this.Restart                       = $Restart
                 $this.StartTime                     = $StartTime
                 $this.SoftwarePackageId             = $SoftwarePackageId
                 $this.Target                        = $Target
                 $this.Type                          = $Type
                 $this.UseTaniumClientTimeZone       = $UseTaniumClientTimeZone
            }
        }
        
        # Validated

        class SinglePackageWithPreNoPost {
            [ValidateNotNullOrEmpty()][string]$Description
            [ValidateNotNullOrEmpty()][int]$DeployedObjectEditId
            [ValidateNotNullOrEmpty()][boolean]$DownloadImmediately
            [ValidateNotNullOrEmpty()][string]$EndTime
            [ValidateNotNullOrEmpty()][bool]$EussAvailableBeforeStart
            [ValidateNotNullOrEmpty()][string]$Name
            [ValidateNotNullOrEmpty()][bool]$OverrideMaintenanceWindows
            [ValidateNotNullOrEmpty()][string]$Operation
            [ValidateNotNullOrEmpty()][hashtable]$PreNotification
            [ValidateNotNullOrEmpty()][bool]$Restart
            [ValidateNotNullOrEmpty()][string]$StartTime
            [ValidateNotNullOrEmpty()][int]$SoftwarePackageId
            [ValidateNotNullOrEmpty()][hashtable]$Target
            [ValidateNotNullOrEmpty()][string]$Type
            [ValidateNotNullOrEmpty()][bool]$UseTaniumClientTimeZone
       
            # Constructor for validation
            SinglePackageWithPreNoPost (
                 [string]$Description,
                 [int]$DeployedObjectEditId,
                 [bool]$DownloadImmediately,
                 [string]$EndTime,
                 [bool]$EussAvailableBeforeStart,
                 [string]$Name,
                 [bool]$OverrideMaintenanceWindows,
                 [string]$Operation,
                 [hashtable]$PreNotification,
                 [bool]$Restart,
                 [string]$StartTime,
                 [int]$SoftwarePackageId,
                 [hashtable]$Target,
                 [string]$Type,
                 [bool]$UseTaniumClientTimeZone
            )
            {
                 $this.Description                   = $Description
                 $this.DeployedObjectEditId          = $DeployedObjectEditId
                 $this.DownloadImmediately           = $DownloadImmediately
                 $this.EndTime                       = $EndTime
                 $this.EussAvailableBeforeStart      = $EussAvailableBeforeStart
                 $this.Name                          = $Name
                 $this.OverrideMaintenanceWindows    = $OverrideMaintenanceWindows
                 $this.Operation                     = $Operation
                 $this.PreNotification               = $PreNotification
                 $this.Restart                       = $Restart
                 $this.StartTime                     = $StartTime
                 $this.SoftwarePackageId             = $SoftwarePackageId
                 $this.Target                        = $Target
                 $this.Type                          = $Type
                 $this.UseTaniumClientTimeZone       = $UseTaniumClientTimeZone
            }
        }
    }

    Process {
        do 
        {
            New-Variable -Name (-join ('ring',$ringLoop)) -Value $ringLoop -Force
    
            $activeRing =  Get-Variable -Name `
                        (-join ('ring',$ringLoop)) | `
                        Select-Object -ExpandProperty 'Name'
    
            $job.$activeRing.targetCriteriaID =     $taniumComputerGroups | `
                                                    Where-Object {$_.name -match "$($job.$activeRing.targetCriteria)"} | `
                                                    Select-Object -ExpandProperty id
            # TODO - Log the class

            switch ($job.$activeRing.class) {
                'OngoingPackageWithPostAndPre' {
                    # Testing

                    Write-Log   -Component "Confirm-DeploymentData" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message    ("Processing $activeRing for: " + `
                                $job.productVendor + ' ' + `
                                $job.productName + ' ' + `
                                $job.guid
                                )
                    
                    $deploymentData = [hashtable]@{
                        deployedObjectEditId                        = $job.currentSoftwarePackageEditId
                        description                                 = "Created by Deployment Automation Framework on $currentDate as part of Job $($job.guid)"
                        downloadImmediately                         = $job.$activeRing.downloadImmediately
                        eussAvailableBeforeStart                    = $job.$activeRing.eussAvailableBeforeStart
                        name                                        = -join ("PSDAT - ",`
                                                                    "$($job.productVendor)",' ',`
                                                                    "$($job.productName)",' ',`
                                                                    "$($job.currentVersion)",' ',`
                                                                    "to $($job.$activeRing.targetCriteria)",`
                                                                    ' - ',`
                                                                    $job.guid)
                        overrideMaintenanceWindows                  = $job.$activeRing.overrideMaintenanceWindows
                        operation                                   = $job.$activeRing.operation
                        restart                                     = $job.$activeRing.restart
                        startTime                                   = $job.$activeRing.deploymentStartTimeString
                        softwarePackageId                           = $job.softwarePackageId
                        target= [hashtable]@{
                            computerGroupIds                        = @($job.$activeRing.targetCriteriaID)
                            questionGroupIds                        = @()
                        }
                        type                                        = $job.$activeRing.type
                        useTaniumClientTimeZone                     = $job.$activeRing.useTaniumClientTimeZone
                        postNotification= [hashtable]@{
                            notifyUser                              = $job.$activeRing.postNotification.notifyUser
                            allowPostpone                           = $job.$activeRing.postNotification.allowPostpone
                            postponeDurationInMinutes               = $job.$activeRing.postNotification.postponeDurationInMinutes
                            countdownToDeadlineInMinutes            = $job.$activeRing.postNotification.countdownToDeadlineInMinutes
                            userPostponementPeriodInMinutesOne      = $job.$activeRing.postNotification.userPostponementPeriodInMinutesOne
                            userPostponementPeriodInMinutesTwo      = $job.$activeRing.postNotification.userPostponementPeriodInMinutesTwo
                            userPostponementPeriodInMinutesThree    = $job.$activeRing.postNotification.userPostponementPeriodInMinutesThree
                            title                                   = $job.$activeRing.postNotification.title
                            body                                    = $job.$activeRing.postNotification.body
                        }
                        preNotification= [hashtable]@{
                            notifyUser                              = $job.$activeRing.preNotification.notifyUser
                            allowPostpone                           = $job.$activeRing.preNotification.allowPostpone
                            postponeDurationInMinutes               = $job.$activeRing.preNotification.postponeDurationInMinutes
                            countdownToDeadlineInMinutes            = $job.$activeRing.preNotification.countdownToDeadlineInMinutes
                            userPostponementPeriodInMinutesOne      = $job.$activeRing.preNotification.userPostponementPeriodInMinutesOne
                            userPostponementPeriodInMinutesTwo      = $job.$activeRing.preNotification.userPostponementPeriodInMinutesTwo
                            userPostponementPeriodInMinutesThree    = $job.$activeRing.preNotification.userPostponementPeriodInMinutesThree
                            title                                   = $job.$activeRing.preNotification.title
                            body                                    = $job.$activeRing.preNotification.body
                        }
                    }
    
                    $validationData =   [OngoingPackageWithPostAndPre]::new(
                        $deploymentData.Description,
                        $deploymentData.DeployedObjectEditId,                                        
                        $deploymentData.DownloadImmediately,
                        $deploymentData.EussAvailableBeforeStart,
                        $deploymentData.Name,
                        $deploymentData.OverrideMaintenanceWindows,
                        $deploymentData.Operation,
                        $deploymentData.PostNotification,
                        $deploymentData.PreNotification,
                        $deploymentData.Restart,
                        $deploymentData.StartTime,
                        $deploymentData.SoftwarePackageId,
                        $deploymentData.Target,
                        $deploymentData.Type,
                        $deploymentData.UseTaniumClientTimeZone
                    )
                }
                'OngoingPackageWithPostNoPre' {
                    # Validated

                    Write-Log   -Component "Confirm-DeploymentData" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message    ("Processing $activeRing for: " + `
                                $job.productVendor + ' ' + `
                                $job.productName + ' ' + `
                                $job.guid
                                )
                    
                    $deploymentData = [hashtable]@{
                        deployedObjectEditId                        = $job.currentSoftwarePackageEditId
                        description                                 = "Created by Deployment Automation Framework on $currentDate as part of Job $($job.guid)"
                        downloadImmediately                         = $job.$activeRing.downloadImmediately
                        eussAvailableBeforeStart                    = $job.$activeRing.eussAvailableBeforeStart
                        name                                        = -join ("PSDAT - ",`
                                                                    "$($job.productVendor)",' ',`
                                                                    "$($job.productName)",' ',`
                                                                    "$($job.currentVersion)",' ',`
                                                                    "to $($job.$activeRing.targetCriteria)",`
                                                                    ' - ',`
                                                                    $job.guid)
                        overrideMaintenanceWindows                  = $job.$activeRing.overrideMaintenanceWindows
                        operation                                   = $job.$activeRing.operation
                        restart                                     = $job.$activeRing.restart
                        startTime                                   = $job.$activeRing.deploymentStartTimeString
                        softwarePackageId                           = $job.softwarePackageId
                        target= [hashtable]@{
                            computerGroupIds                        = @($job.$activeRing.targetCriteriaID)
                            questionGroupIds                        = @()
                        }
                        type                                        = $job.$activeRing.type
                        useTaniumClientTimeZone                     = $job.$activeRing.useTaniumClientTimeZone
                        postNotification= [hashtable]@{
                            notifyUser                              = $job.$activeRing.postNotification.notifyUser
                            allowPostpone                           = $job.$activeRing.postNotification.allowPostpone
                            postponeDurationInMinutes               = $job.$activeRing.postNotification.postponeDurationInMinutes
                            countdownToDeadlineInMinutes            = $job.$activeRing.postNotification.countdownToDeadlineInMinutes
                            userPostponementPeriodInMinutesOne      = $job.$activeRing.postNotification.userPostponementPeriodInMinutesOne
                            userPostponementPeriodInMinutesTwo      = $job.$activeRing.postNotification.userPostponementPeriodInMinutesTwo
                            userPostponementPeriodInMinutesThree    = $job.$activeRing.postNotification.userPostponementPeriodInMinutesThree
                            title                                   = $job.$activeRing.postNotification.title
                            body                                    = $job.$activeRing.postNotification.body
                        }
                    }
    
                    $validationData =   [OngoingPackageWithPostNoPre]::new(
                        $deploymentData.Description,
                        $deploymentData.DeployedObjectEditId,                                        
                        $deploymentData.DownloadImmediately,
                        $deploymentData.EussAvailableBeforeStart,
                        $deploymentData.Name,
                        $deploymentData.OverrideMaintenanceWindows,
                        $deploymentData.Operation,
                        $deploymentData.PostNotification,
                        $deploymentData.Restart,
                        $deploymentData.StartTime,
                        $deploymentData.SoftwarePackageId,
                        $deploymentData.Target,
                        $deploymentData.Type,
                        $deploymentData.UseTaniumClientTimeZone
                    )
                }
                'OngoingPackageWithPreNoPost' {
                    # Validated

                    Write-Log   -Component "Confirm-DeploymentData" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message    ("Processing $activeRing for: " + `
                                $job.productVendor + ' ' + `
                                $job.productName + ' ' + `
                                $job.guid
                                )
                    
                    $deploymentData = [hashtable]@{
                        deployedObjectEditId                        = $job.currentSoftwarePackageEditId
                        description                                 = "Created by Deployment Automation Framework on $currentDate as part of Job $($job.guid)"
                        downloadImmediately                         = $job.$activeRing.downloadImmediately
                        eussAvailableBeforeStart                    = $job.$activeRing.eussAvailableBeforeStart
                        name                                        = -join ("PSDAT - ",`
                                                                    "$($job.productVendor)",' ',`
                                                                    "$($job.productName)",' ',`
                                                                    "$($job.currentVersion)",' ',`
                                                                    "to $($job.$activeRing.targetCriteria)",`
                                                                    ' - ',`
                                                                    $job.guid)
                        overrideMaintenanceWindows                  = $job.$activeRing.overrideMaintenanceWindows
                        operation                                   = $job.$activeRing.operation
                        restart                                     = $job.$activeRing.restart
                        startTime                                   = $job.$activeRing.deploymentStartTimeString
                        softwarePackageId                           = $job.softwarePackageId
                        target= [hashtable]@{
                            computerGroupIds                        = @($job.$activeRing.targetCriteriaID)
                            questionGroupIds                        = @()
                        }
                        type                                        = $job.$activeRing.type
                        useTaniumClientTimeZone                     = $job.$activeRing.useTaniumClientTimeZone
                        preNotification= [hashtable]@{
                            notifyUser                              = $job.$activeRing.preNotification.notifyUser
                            allowPostpone                           = $job.$activeRing.preNotification.allowPostpone
                            postponeDurationInMinutes               = $job.$activeRing.preNotification.postponeDurationInMinutes
                            countdownToDeadlineInMinutes            = $job.$activeRing.preNotification.countdownToDeadlineInMinutes
                            userPostponementPeriodInMinutesOne      = $job.$activeRing.preNotification.userPostponementPeriodInMinutesOne
                            userPostponementPeriodInMinutesTwo      = $job.$activeRing.preNotification.userPostponementPeriodInMinutesTwo
                            userPostponementPeriodInMinutesThree    = $job.$activeRing.preNotification.userPostponementPeriodInMinutesThree
                            title                                   = $job.$activeRing.preNotification.title
                            body                                    = $job.$activeRing.preNotification.body
                        }
                    }
    
                    $validationData =   [OngoingPackageWithPreNoPost]::new(
                        $deploymentData.description,
                        $deploymentData.deployedObjectEditId,                                        
                        $deploymentData.downloadImmediately,
                        $deploymentData.eussAvailableBeforeStart,
                        $deploymentData.name,
                        $deploymentData.overrideMaintenanceWindows,
                        $deploymentData.operation,
                        $deploymentData.preNotification,
                        $deploymentData.restart,
                        $deploymentData.startTime,
                        $deploymentData.softwarePackageId,
                        $deploymentData.target,
                        $deploymentData.type,
                        $deploymentData.useTaniumClientTimeZone
                    )
                }
                'OngoingPackageDeploymentSilent' {
                    #Confirmed working

                    Write-Log   -Component "Confirm-DeploymentData" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message    ("Processing $activeRing for: " + `
                                $job.productVendor + ' ' + `
                                $job.productName + ' ' + `
                                $job.guid
                                )
                    
                    $deploymentData = [hashtable]@{
                        deployedObjectEditId          = $job.currentSoftwarePackageEditId
                        description                   = "Created by Deployment Automation Framework on $currentDate as part of Job $($job.guid)"
                        downloadImmediately           = $job.$activeRing.downloadImmediately
                        eussAvailableBeforeStart      = $job.$activeRing.eussAvailableBeforeStart
                        name                          = -join ("PSDAT - ",`
                                                        "$($job.productVendor)",' ',`
                                                        "$($job.productName)",' ',`
                                                        "$($job.currentVersion)",' ',`
                                                        "to $($job.$activeRing.targetCriteria)",`
                                                        ' - ',`
                                                        $job.guid)
                        overrideMaintenanceWindows    = $job.$activeRing.overrideMaintenanceWindows
                        operation                     = $job.$activeRing.operation
                        restart                       = $job.$activeRing.restart
                        startTime                     = $job.$activeRing.deploymentStartTimeString
                        softwarePackageId             = $job.softwarePackageId
                        target= [hashtable]@{
                            computerGroupIds          = @($job.$activeRing.targetCriteriaID)
                            questionGroupIds          = @()
                        }
                        type                          = $job.$activeRing.type
                        useTaniumClientTimeZone       = $job.$activeRing.useTaniumClientTimeZone
                    }
    
                    $validationData =   [OngoingPackageDeploymentSilent]::new(
                        $deploymentData.description,
                        $deploymentData.deployedObjectEditId,                                        
                        $deploymentData.downloadImmediately,
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
                'SinglePackageSilent' {
                    # Validated

                    Write-Log   -Component "Confirm-DeploymentData" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message    ("Processing $activeRing for: " + `
                                $job.productVendor + ' ' + `
                                $job.productName + ' ' + `
                                $job.guid
                                )
                    
                    $deploymentData = [hashtable]@{
                        deployedObjectEditId          = $job.currentSoftwarePackageEditId
                        description                   = "Created by Deployment Automation Framework on $currentDate as part of Job $($job.guid)"
                        downloadImmediately           = $job.$activeRing.downloadImmediately
                        eussAvailableBeforeStart      = $job.$activeRing.eussAvailableBeforeStart
                        name                          = -join ("PSDAT - ",`
                                                        "$($job.productVendor)",' ',`
                                                        "$($job.productName)",' ',`
                                                        "$($job.currentVersion)",' ',`
                                                        "to $($job.$activeRing.targetCriteria)",`
                                                        ' - ',`
                                                        $job.guid)
                        overrideMaintenanceWindows    = $job.$activeRing.overrideMaintenanceWindows
                        operation                     = $job.$activeRing.operation
                        restart                       = $job.$activeRing.restart
                        startTime                     = $job.$activeRing.deploymentStartTimeString
                        endTime                       = $job.$activeRing.deploymentEndTimeString
                        softwarePackageId             = $job.softwarePackageId
                        target= [hashtable]@{
                            computerGroupIds          = @($job.$activeRing.targetCriteriaID)
                            questionGroupIds          = @()
                        }
                        type                          = $job.$activeRing.type
                        useTaniumClientTimeZone       = $job.$activeRing.useTaniumClientTimeZone
                    }
    
                    $validationData =   [SinglePackageSilent]::new(
                        $deploymentData.description,
                        $deploymentData.deployedObjectEditId,                                        
                        $deploymentData.downloadImmediately,
                        $deploymentData.eussAvailableBeforeStart,
                        $deploymentData.name,
                        $deploymentData.overrideMaintenanceWindows,
                        $deploymentData.operation,
                        $deploymentData.restart,
                        $deploymentData.startTime,
                        $deploymentData.endTime,
                        $deploymentData.softwarePackageId,
                        $deploymentData.target,
                        $deploymentData.type,
                        $deploymentData.useTaniumClientTimeZone
                    )
                }
                'SinglePackageWithPostAndPre' {
                    # Test

                    Write-Log   -Component "Confirm-DeploymentData" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message    ("Processing $activeRing for: " + `
                                $job.productVendor + ' ' + `
                                $job.productName + ' ' + `
                                $job.guid
                                )
                    
                    $deploymentData = [hashtable]@{
                        deployedObjectEditId                        = $job.currentSoftwarePackageEditId
                        description                                 = "Created by Deployment Automation Framework on $currentDate as part of Job $($job.guid)"
                        downloadImmediately                         = $job.$activeRing.downloadImmediately
                        eussAvailableBeforeStart                    = $job.$activeRing.eussAvailableBeforeStart
                        name                                        = -join ("PSDAT - ",`
                                                                        "$($job.productVendor)",' ',`
                                                                        "$($job.productName)",' ',`
                                                                        "$($job.currentVersion)",' ',`
                                                                        "to $($job.$activeRing.targetCriteria)",`
                                                                        ' - ',`
                                                                        $job.guid)
                        overrideMaintenanceWindows                  = $job.$activeRing.overrideMaintenanceWindows
                        operation                                   = $job.$activeRing.operation
                        restart                                     = $job.$activeRing.restart
                        startTime                                   = $job.$activeRing.deploymentStartTimeString
                        endTime                                     = $job.$activeRing.deploymentEndTimeString
                        softwarePackageId                           = $job.softwarePackageId
                        target= [hashtable]@{
                                computerGroupIds                        = @($job.$activeRing.targetCriteriaID)
                                questionGroupIds                        = @()
                        }
                        type                                        = $job.$activeRing.type
                        useTaniumClientTimeZone                     = $job.$activeRing.useTaniumClientTimeZone
                        postNotification= [hashtable]@{
                                notifyUser                              = $job.$activeRing.postNotification.notifyUser
                                allowPostpone                           = $job.$activeRing.postNotification.allowPostpone
                                postponeDurationInMinutes               = $job.$activeRing.postNotification.postponeDurationInMinutes
                                countdownToDeadlineInMinutes            = $job.$activeRing.postNotification.countdownToDeadlineInMinutes
                                userPostponementPeriodInMinutesOne      = $job.$activeRing.postNotification.userPostponementPeriodInMinutesOne
                                userPostponementPeriodInMinutesTwo      = $job.$activeRing.postNotification.userPostponementPeriodInMinutesTwo
                                userPostponementPeriodInMinutesThree    = $job.$activeRing.postNotification.userPostponementPeriodInMinutesThree
                                title                                   = $job.$activeRing.postNotification.title
                                body                                    = $job.$activeRing.postNotification.body
                        }
                        preNotification= [hashtable]@{
                                notifyUser                              = $job.$activeRing.preNotification.notifyUser
                                allowPostpone                           = $job.$activeRing.preNotification.allowPostpone
                                postponeDurationInMinutes               = $job.$activeRing.preNotification.postponeDurationInMinutes
                                countdownToDeadlineInMinutes            = $job.$activeRing.preNotification.countdownToDeadlineInMinutes
                                userPostponementPeriodInMinutesOne      = $job.$activeRing.preNotification.userPostponementPeriodInMinutesOne
                                userPostponementPeriodInMinutesTwo      = $job.$activeRing.preNotification.userPostponementPeriodInMinutesTwo
                                userPostponementPeriodInMinutesThree    = $job.$activeRing.preNotification.userPostponementPeriodInMinutesThree
                                title                                   = $job.$activeRing.preNotification.title
                                body                                    = $job.$activeRing.preNotification.body
                        }
                    }
    
                $validationData =   [SinglePackageWithPostAndPre]::new(
                    $deploymentData.Description,
                    $deploymentData.DeployedObjectEditId,                                        
                    $deploymentData.DownloadImmediately,
                    $deploymentData.EndTime,
                    $deploymentData.EussAvailableBeforeStart,
                    $deploymentData.Name,
                    $deploymentData.OverrideMaintenanceWindows,
                    $deploymentData.Operation,
                    $deploymentData.PostNotification,
                    $deploymentData.PreNotification,
                    $deploymentData.Restart,
                    $deploymentData.StartTime,
                    $deploymentData.SoftwarePackageId,
                    $deploymentData.Target,
                    $deploymentData.Type,
                    $deploymentData.UseTaniumClientTimeZone
                )
                }
                'SinglePackageWithPostNoPre' {
                    Write-Log   -Component "Confirm-DeploymentData" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message    ("Processing $activeRing for: " + `
                                $job.productVendor + ' ' + `
                                $job.productName + ' ' + `
                                $job.guid
                                )
                    
                    $deploymentData = [hashtable]@{
                        deployedObjectEditId                            = $job.currentSoftwarePackageEditId
                        description                                     = "Created by Deployment Automation Framework on $currentDate as part of Job $($job.guid)"
                        downloadImmediately                             = $job.$activeRing.downloadImmediately
                        eussAvailableBeforeStart                        = $job.$activeRing.eussAvailableBeforeStart
                        name                                            = -join ("PSDAT - ",`
                                                                        "$($job.productVendor)",' ',`
                                                                        "$($job.productName)",' ',`
                                                                        "$($job.currentVersion)",' ',`
                                                                        "to $($job.$activeRing.targetCriteria)",`
                                                                        ' - ',`
                                                                        $job.guid)
                        overrideMaintenanceWindows                      = $job.$activeRing.overrideMaintenanceWindows
                        operation                                       = $job.$activeRing.operation
                        restart                                         = $job.$activeRing.restart
                        startTime                                       = $job.$activeRing.deploymentStartTimeString
                        endTime                                         = $job.$activeRing.deploymentEndTimeString
                        softwarePackageId                               = $job.softwarePackageId
                        target= [hashtable]@{
                            computerGroupIds                            = @($job.$activeRing.targetCriteriaID)
                            questionGroupIds                            = @()
                        }
                        type                                            = $job.$activeRing.type
                        useTaniumClientTimeZone                         = $job.$activeRing.useTaniumClientTimeZone
                        postNotification= [hashtable]@{
                                notifyUser                              = $job.$activeRing.postNotification.notifyUser
                                allowPostpone                           = $job.$activeRing.postNotification.allowPostpone
                                postponeDurationInMinutes               = $job.$activeRing.postNotification.postponeDurationInMinutes
                                countdownToDeadlineInMinutes            = $job.$activeRing.postNotification.countdownToDeadlineInMinutes
                                userPostponementPeriodInMinutesOne      = $job.$activeRing.postNotification.userPostponementPeriodInMinutesOne
                                userPostponementPeriodInMinutesTwo      = $job.$activeRing.postNotification.userPostponementPeriodInMinutesTwo
                                userPostponementPeriodInMinutesThree    = $job.$activeRing.postNotification.userPostponementPeriodInMinutesThree
                                title                                   = $job.$activeRing.postNotification.title
                                body                                    = $job.$activeRing.postNotification.body
                        }
                    }
    
                $validationData =   [SinglePackageWithPostNoPre]::new(
                    $deploymentData.Description,
                    $deploymentData.DeployedObjectEditId,                                        
                    $deploymentData.DownloadImmediately,
                    $deploymentData.EndTime,
                    $deploymentData.EussAvailableBeforeStart,
                    $deploymentData.Name,
                    $deploymentData.OverrideMaintenanceWindows,
                    $deploymentData.Operation,
                    $deploymentData.PostNotification,
                    $deploymentData.Restart,
                    $deploymentData.StartTime,
                    $deploymentData.SoftwarePackageId,
                    $deploymentData.Target,
                    $deploymentData.Type,
                    $deploymentData.UseTaniumClientTimeZone
                )
                }
                'SinglePackageWithPreNoPost' {
                    Write-Log   -Component "Confirm-DeploymentData" `
                    -Type 1 `
                    -LogFile $scriptLogFile `
                    -Message    ("Processing $activeRing for: " + `
                                $job.productVendor + ' ' + `
                                $job.productName + ' ' + `
                                $job.guid
                                )
                    
                    $deploymentData = [hashtable]@{
                        deployedObjectEditId                            = $job.currentSoftwarePackageEditId
                        description                                     = "Created by Deployment Automation Framework on $currentDate as part of Job $($job.guid)"
                        downloadImmediately                             = $job.$activeRing.downloadImmediately
                        eussAvailableBeforeStart                        = $job.$activeRing.eussAvailableBeforeStart
                        name                                            = -join ("PSDAT - ",`
                                                                        "$($job.productVendor)",' ',`
                                                                        "$($job.productName)",' ',`
                                                                        "$($job.currentVersion)",' ',`
                                                                        "to $($job.$activeRing.targetCriteria)",`
                                                                        ' - ',`
                                                                        $job.guid)
                        overrideMaintenanceWindows                      = $job.$activeRing.overrideMaintenanceWindows
                        operation                                       = $job.$activeRing.operation
                        restart                                         = $job.$activeRing.restart
                        startTime                                       = $job.$activeRing.deploymentStartTimeString
                        endTime                                         = $job.$activeRing.deploymentEndTimeString
                        softwarePackageId                               = $job.softwarePackageId
                        target= [hashtable]@{
                            computerGroupIds                            = @($job.$activeRing.targetCriteriaID)
                            questionGroupIds                            = @()
                        }
                        type                                            = $job.$activeRing.type
                        useTaniumClientTimeZone                         = $job.$activeRing.useTaniumClientTimeZone
                        preNotification= [hashtable]@{
                                notifyUser                              = $job.$activeRing.preNotification.notifyUser
                                allowPostpone                           = $job.$activeRing.preNotification.allowPostpone
                                postponeDurationInMinutes               = $job.$activeRing.preNotification.postponeDurationInMinutes
                                countdownToDeadlineInMinutes            = $job.$activeRing.preNotification.countdownToDeadlineInMinutes
                                userPostponementPeriodInMinutesOne      = $job.$activeRing.preNotification.userPostponementPeriodInMinutesOne
                                userPostponementPeriodInMinutesTwo      = $job.$activeRing.preNotification.userPostponementPeriodInMinutesTwo
                                userPostponementPeriodInMinutesThree    = $job.$activeRing.preNotification.userPostponementPeriodInMinutesThree
                                title                                   = $job.$activeRing.preNotification.title
                                body                                    = $job.$activeRing.preNotification.body
                        }
                    }
    
                $validationData =   [SinglePackageWithPreNoPost]::new(
                    $deploymentData.Description,
                    $deploymentData.DeployedObjectEditId,                                        
                    $deploymentData.DownloadImmediately,
                    $deploymentData.EndTime,
                    $deploymentData.EussAvailableBeforeStart,
                    $deploymentData.Name,
                    $deploymentData.OverrideMaintenanceWindows,
                    $deploymentData.Operation,
                    $deploymentData.PreNotification,
                    $deploymentData.Restart,
                    $deploymentData.StartTime,
                    $deploymentData.SoftwarePackageId,
                    $deploymentData.Target,
                    $deploymentData.Type,
                    $deploymentData.UseTaniumClientTimeZone
                )
                }
                
            }

            if ($null -ne $validationData){
                Write-Log   -Component "Confirm-DeploymentData" -Type 1 `
                            -LogFile $scriptLogFile `
                            -Message    ("Deployment structure validated for: " + `
                                        $job.productVendor + ' ' + `
                                        $job.productName + ' ' + `
                                        $job.guid + ' ' + `
                                        $activeRing
                                        )
                
                $job.$activeRing.classValidated = $true

                $job.$activeRing | Add-Member -MemberType NoteProperty -Name deploymentData -Value $deploymentData -Force
            }
            else {
                    $job.$activeRing.classValidated = $false
            }

            if ($null -ne $deploymentData){
                Clear-Variable -Name deploymentData -ErrorAction SilentlyContinue
            }
            
            if ($null -ne $validationData){
                Clear-Variable -Name validationData -ErrorAction SilentlyContinue
            }

            $ringLoop++

            #if ($job.$activeRing.class -eq 'OngoingPackageDeploymentSilent') {
            #}
        }
        until ($ringLoop -gt $ringCount)
    
        Remove-Variable ringCount
        Remove-Variable ringLoop
    }

    End {
            return $Job
    }
}