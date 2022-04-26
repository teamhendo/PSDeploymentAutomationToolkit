function Start-PatchDeploymentProcessing {
[CmdletBinding()]
param (
	[Parameter(Mandatory=$true, 
	ValueFromPipeline=$true)]
	[ValidateNotNull()]
	$Job,
	[Parameter(Mandatory=$true, 
	ValueFromPipeline=$true)]
	[ValidateNotNull()]
	$ScriptLogFile
)

Begin {
	[hashtable]$ringHashTable = @{}
	[int]$ringCount = $( $job | Get-Member | Where-Object { $_.name -like "ring*" } ).count
	[int]$ringLoop = 1
}

Process {
    do 
    {
        $activeRing = 'ring' + $ringLoop

        if ($job.type -eq 'patch' -and $null -eq $job.$activeRing.deployedOn) 
        {
            Write-Log -Component "DeploymentAutomationToolkit:PatchDeploymentProcessing" -Type 1 `
                      -LogFile $scriptLogFile `
                      -Message ("Creating deployment for: " + `
                               $job.productVendor + ' ' + `
                               $job.productName + ' ' + `
                               $job.guid + ' ' + `
                               $activeRing
                               )

            if ($job.$activeRing.classValidated -eq $true) 
            {
                $deploymentOutcome = Submit-TaniumPatchDeployment -Data $job.$activeRing.deploymentData `
                                                                  -ScriptLogFile $ScriptLogFile
            }
            else 
            {
                Write-Log -Component "DeploymentAutomationToolkit:PatchDeploymentProcessing" -Type 1 `
                          -LogFile $scriptLogFile `
                          -Message ("Deployment data did not pass class validation: " + `
                                   $job.productVendor + ' ' + `
                                   $job.productName + ' ' + `
                                   $job.guid + ' ' + `
                                   $activeRing
                                   )

                break
            }

            if ($deploymentOutcome.successfulDeployment -eq $true) 
            {

                $job.$activeRing.deployedOn     = $deploymentOutcome.deploymentObject.createdAt
                $job.$activeRing.deploymentID   = $deploymentOutcome.deploymentObject.id
                
                $job | ConvertTo-Json -Depth 100 | Out-File (-join ($scriptDirectory, $($job.jobFileLocation))) -Force

            }
        }
        elseif ($job.type -eq 'patch' -and $null -ne $job.$activeRing.deployedOn) 
        {
            Write-Log -Component "DeploymentAutomationToolkit:PatchDeploymentProcessing" -Type 1 `
                      -LogFile $scriptLogFile `
                      -Message ("This ring has already been deployed. Skipping over: " + `
                               $job.productVendor + ' ' + `
                               $job.productName + ' ' + `
                               $job.guid + ' ' + `
                               $activeRing
                               )
        }

        if ($QuickTest -eq $true -and $ringLoop -ne $ringCount)
        {
            Write-Log -Component "DeploymentAutomationToolkit:PatchDeploymentProcessing" `
                      -Type 1 `
                      -LogFile $scriptLogFile `
                      -Message 'Beginning 5 second cooldown for deployment processing.'

            Start-Sleep -Seconds 5
        }
        elseif ($ringLoop -ne $ringCount) 
        {
            Write-Log -Component "DeploymentAutomationToolkit:PatchDeploymentProcessing" `
                      -Type 1 `
                      -LogFile $scriptLogFile `
                      -Message 'Beginning 30 second cooldown for deployment processing.' 

            Start-Sleep -Seconds 30
        }

        $ringLoop++
    }    
    until ($ringLoop -gt $ringCount)
    
    # Loop through rings to determine ring completion statuses

    $ringLoop = 1

    do 
    {
        $activeRing = 'ring' + $ringLoop
        
        if ($job.$activeRing.deployedOn) {
            $ringHashTable.Add("$activeRing",'complete')
        }
        else {
            $ringHashTable.Add("$activeRing",'incomplete')
        }

        $ringLoop++
    }
    until ($ringLoop -gt $ringCount)

    if ($ringHashTable.Values -notcontains 'incomplete') 
    {
        Write-Log -Component "DeploymentAutomationToolkit:PatchDeploymentProcessing" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message ("All rings deployed for: " + `
                           $job.productVendor + ' ' + `
                           $job.productName + ' ' + `
                           $job.guid
                           )

        $job.allRingsDeployed = $true
    }
    else 
    {
        Write-Log -Component "DeploymentAutomationToolkit:PatchDeploymentProcessing" `
                  -Type 1 `
                  -LogFile $scriptLogFile `
                  -Message ("One or more rings not deployed for: " + `
                           $job.productVendor + ' ' + `
                           $job.productName + ' ' + `
                           $job.guid
                           )
        
        $job.allRingsDeployed = $false
    }

    $job | ConvertTo-Json -Depth 100 | Out-File (-join ($scriptDirectory, $($job.jobFileLocation))) -Force

    Remove-Variable ringCount
    Remove-Variable ringHashTable
    Remove-Variable ringLoop
}

End {
	return $Job
}
}