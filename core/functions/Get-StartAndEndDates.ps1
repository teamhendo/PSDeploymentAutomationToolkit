function Get-StartAndEndDates {
	[CmdletBinding()]
	param (
          [Parameter(Mandatory=$true, 
		ValueFromPipeline=$true)]
		[ValidateNotNull()]
		$Job,
		[Parameter(Mandatory=$true, 
		ValueFromPipeline=$true)]
		[ValidateNotNull()]
		$ScriptLogFile,
          [Parameter(Mandatory=$false, 
		ValueFromPipeline=$true)]
		[ValidateNotNull()]
		$StartToday
	)
    
     Begin {
          [int]$ringCount = $($job | Get-Member | Where-Object {$_.name -like "ring*"}).count
          [int]$ringLoop = 1
     }

     Process {
          if ($StartToday -eq $false -or $null -eq $StartToday) {
               $patchTuesdayOrToday = Get-PatchTuesday
          }
          else 
          {
               $patchTuesdayOrToday = Get-Date
          }

          do 
          {
               New-Variable -Name (-join ('ring',$ringLoop)) -Value $ringLoop -Force
          
               $activeRing =  Get-Variable -Name `
                              (-join ('ring',$ringLoop)) | `
                              Select-Object -ExpandProperty 'Name'
         
               # TODO - Make something sensible.

               switch ($job.$activeRing.type) {
                    'single' {
                         $startDate = $($patchTuesdayOrToday).AddDays($job.$activeRing.startDateOffsetInDays).ToString("yyyy-MM-dd")
                         
                         $startTime = $(
                                        if ($job.$activeRing.deploymentStartTime -ne '21:00') `
                                             {$job.$activeRing.deploymentStartTime}`
                                        else {'21:00'}
                                      )
                         $stopDate  = $($patchTuesdayOrToday).AddDays($($job.$activeRing.startDateOffsetInDays) + `
                                             ($job.$activeRing.deploymentLengthInDays)).ToString("yyyy-MM-dd")
                         
                         $stopTime  = $job.$activeRing.deploymentStopTime
                         
                         $job.$activeRing.deploymentStartTimeString = -join ("$startDate",'T',"$startTime",':00.000Z')
                         
                         $job.$activeRing.deploymentStopTimeString = -join ("$stopDate",'T',"$stopTime",':00.000Z')
                    }
                    'ongoing'{
                         $startDate = $($patchTuesdayOrToday).AddDays($job.$activeRing.startDateOffsetInDays).ToString("yyyy-MM-dd")
                         
                         $startTime = $(
                                        if   ($job.$activeRing.deploymentStartTime -ne '21:00') `
                                             {$job.$activeRing.deploymentStartTime}`
                                        else {'21:00'}
                                      )
                         
                         $job.$activeRing.deploymentStartTimeString = -join ("$startDate",'T',"$startTime",':00.000Z')
                    }
               }
               $ringLoop++
          }
          until ($ringLoop -gt $ringCount)
    
        Remove-Variable ringCount
        Remove-Variable ringLoop
     }

     End {
          return $Job
     }
}