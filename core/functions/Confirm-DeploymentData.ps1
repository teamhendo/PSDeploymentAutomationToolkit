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

    # Class Validated
    ########### CLASS AMENDMENTS to [string]$taniumGroupIds NOT VALIDATED

    class SinglePatchlistWithPost {
        [ValidateNotNullOrEmpty()][string]$Description
        [ValidateNotNullOrEmpty()][boolean]$DownloadImmediately
        [ValidateNotNullOrEmpty()][string]$EndTime
        [ValidateNotNullOrEmpty()][bool]$EussAvailableBeforeStart
        [ValidateNotNullOrEmpty()][string]$Name
        [ValidateNotNullOrEmpty()][string]$OSType
        [ValidateNotNullOrEmpty()][bool]$OverrideBlacklists
        [ValidateNotNullOrEmpty()][bool]$OverrideMaintenanceWindows
        [ValidateNotNullOrEmpty()][string]$PatchListIdsWithLatestVersion
        [ValidateNotNullOrEmpty()][bool]$Restart
        [ValidateNotNullOrEmpty()][hashtable]$RestartClientNotification
        [ValidateNotNullOrEmpty()][string]$StartTime
        [ValidateNotNullOrEmpty()][string]$targetedComputerGroupIds
        [ValidateNotNullOrEmpty()][string]$taniumGroupIds
        [ValidateNotNullOrEmpty()][string]$Type
        [ValidateNotNullOrEmpty()][bool]$UseTaniumClientTimeZone
    
        # Constructor for validation
        SinglePatchlistWithPost (
            [string]$Description,
            [bool]$DownloadImmediately,
            [string]$EndTime,
            [bool]$EussAvailableBeforeStart,
            [string]$Name,
            [string]$OSType,
            [bool]$OverrideBlacklists,
            [bool]$OverrideMaintenanceWindows,
            [string]$PatchListIdsWithLatestVersion,
            [bool]$Restart,
            [hashtable]$RestartClientNotification,
            [string]$StartTime,
            [string]$targetedComputerGroupIds,
            [string]$taniumGroupIds,
            [string]$Type,
            [bool]$UseTaniumClientTimeZone
        )
        {
            $this.Description                    = $Description
            $this.DownloadImmediately            = $DownloadImmediately
            $this.EndTime                        = $EndTime
            $this.EussAvailableBeforeStart       = $EussAvailableBeforeStart
            $this.Name                           = $Name
            $this.OSType                         = $OSType
            $this.OverrideBlacklists             = $OverrideBlacklists
            $this.OverrideMaintenanceWindows     = $OverrideMaintenanceWindows
            $this.PatchListIdsWithLatestVersion  = $PatchListIdsWithLatestVersion
            $this.Restart                        = $Restart
            $this.RestartClientNotification      = $RestartClientNotification
            $this.StartTime                      = $StartTime
            $this.targetedComputerGroupIds       = $targetedComputerGroupIds
            $this.taniumGroupIds                 = $taniumGroupIds
            $this.Type                           = $Type
            $this.UseTaniumClientTimeZone        = $UseTaniumClientTimeZone
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

        switch ($job.$activeRing.class) {
            'OngoingPackageWithPostAndPre' {

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
                    description                                 = "Created by Deployment Automation Toolkit on $currentDate as part of Job $($job.guid)"
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
                    description                                 = "Created by Deployment Automation Toolkit on $currentDate as part of Job $($job.guid)"
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
                    description                                 = "Created by Deployment Automation Toolkit on $currentDate as part of Job $($job.guid)"
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
                    description                   = "Created by Deployment Automation Toolkit on $currentDate as part of Job $($job.guid)"
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
                    description                   = "Created by Deployment Automation Toolkit on $currentDate as part of Job $($job.guid)"
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
                    description                                 = "Created by Deployment Automation Toolkit on $currentDate as part of Job $($job.guid)"
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
                    description                                     = "Created by Deployment Automation Toolkit on $currentDate as part of Job $($job.guid)"
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
                        notifyUser                                  = $job.$activeRing.postNotification.notifyUser
                        allowPostpone                               = $job.$activeRing.postNotification.allowPostpone
                        postponeDurationInMinutes                   = $job.$activeRing.postNotification.postponeDurationInMinutes
                        countdownToDeadlineInMinutes                = $job.$activeRing.postNotification.countdownToDeadlineInMinutes
                        userPostponementPeriodInMinutesOne          = $job.$activeRing.postNotification.userPostponementPeriodInMinutesOne
                        userPostponementPeriodInMinutesTwo          = $job.$activeRing.postNotification.userPostponementPeriodInMinutesTwo
                        userPostponementPeriodInMinutesThree        = $job.$activeRing.postNotification.userPostponementPeriodInMinutesThree
                        title                                       = $job.$activeRing.postNotification.title
                        body                                        = $job.$activeRing.postNotification.body
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
                    description                                     = "Created by Deployment Automation Toolkit on $currentDate as part of Job $($job.guid)"
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
                        notifyUser                                  = $job.$activeRing.preNotification.notifyUser
                        allowPostpone                               = $job.$activeRing.preNotification.allowPostpone
                        postponeDurationInMinutes                   = $job.$activeRing.preNotification.postponeDurationInMinutes
                        countdownToDeadlineInMinutes                = $job.$activeRing.preNotification.countdownToDeadlineInMinutes
                        userPostponementPeriodInMinutesOne          = $job.$activeRing.preNotification.userPostponementPeriodInMinutesOne
                        userPostponementPeriodInMinutesTwo          = $job.$activeRing.preNotification.userPostponementPeriodInMinutesTwo
                        userPostponementPeriodInMinutesThree        = $job.$activeRing.preNotification.userPostponementPeriodInMinutesThree
                        title                                       = $job.$activeRing.preNotification.title
                        body                                        = $job.$activeRing.preNotification.body
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
            'SinglePatchlistWithPost' {
                # NOT VALIDATED

                Write-Log   -Component "Confirm-DeploymentData" `
                -Type 1 `
                -LogFile $scriptLogFile `
                -Message    ("Processing $activeRing for: " + `
                            $job.productVendor + ' ' + `
                            $job.productName + ' ' + `
                            "to $($job.$activeRing.name)" + ' ' + `
                            $job.guid
                            )
                
                $deploymentData = @{
                    description                                 = "Created by Deployment Automation Toolkit on $currentDate as part of Job $($job.guid)"
                    distributeOverTimeMinutes                   = $job.$activeRing.distributeOverTimeMinutes
                    downloadImmediately                         = $job.$activeRing.downloadImmediately
                    endTime                                     = $job.$activeRing.deploymentEndTimeString
                    eussAvailableBeforeStart                    = $job.$activeRing.eussAvailableBeforeStart
                    name                                        = $job.$activeRing.Name
                    overrideBlacklists                          = $job.$activeRing.overrideBlacklists
                    overrideMaintenanceWindows                  = $job.$activeRing.overrideMaintenanceWindows
                    patchListIdsWithLatestVersion               = @([int]$($job.$activeRing.patchListIdsWithLatestVersion))
                    restart                                     = $job.$activeRing.restart
                    restartClientNotification = [hashtable]@{
                        allowPostpone                           = $job.$activeRing.restartClientNotification.allowPostpone
                        body                                    = "Security patches have been applied to this computer. A reboot will eventually be forced to complete installation. In order to prevent losing unsaved documents at the deadline, please save any open documents and click the 'Restart Now' button."
                        bodyImage                               = "data:image/png;base64,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"
                        countdownToDeadlineInMinutes            = 15
                        gentleNotificationDurationInMinutes     = 0.5
                        icon                                    = "data:image/png;base64,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"
                        postponeDurationInMinutes               = 540
                        title                                   = "Reboot Required"
                        userPostponementPeriodInMinutesOne      = 60
                        userPostponementPeriodInMinutesTwo      = 180
                        userPostponementPeriodInMinutesThree    = 300
                    }
                    startTime                                   = $job.$activeRing.deploymentStartTimeString
                    targetedComputerGroupIds                    = @([int]$($job.$activeRing.targetedComputerGroupIds))
                    taniumGroupIds                              = @([int]$($job.$activeRing.targetedComputerGroupIds))
                    type                                        = $job.$activeRing.operation
                    useTaniumClientTimeZone                     = $job.$activeRing.useTaniumClientTimeZone
                }

                $validationData =   [SinglePatchlistWithPost]::new(
                    $deploymentData.Description,
                    $deploymentData.DistributeOverTimeMinutes,                                        
                    $deploymentData.DownloadImmediately,
                    $deploymentData.EndTime,
                    $deploymentData.EussAvailableBeforeStart,
                    $deploymentData.Name,
                    $deploymentData.OverrideBlacklists,
                    $deploymentData.OverrideMaintenanceWindows,
                    $deploymentData.PatchListIdsWithLatestVersion,
                    $deploymentData.Restart,
                    $deploymentData.RestartClientNotification,
                    $deploymentData.StartTime,
                    $deploymentData.targetedComputerGroupIds,
                    $deploymentData.taniumGroupIds,
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