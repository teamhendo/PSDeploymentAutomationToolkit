function Stop-AllActiveTaniumDeployments {
     [CmdletBinding()]
     param (
          [Parameter(Mandatory=$false)]
          [ValidateSet('All','Deploy','Patch')]
          [string] $Mode = 'All'
     )
     
     if ($Mode -eq 'All' -or $Mode -eq 'Deploy')
     {
          # Tanium Deploy Deployments

          $deployments = Get-TaniumDeployDeployment | Where-Object {$_.statusLabel -like "Active*"}

          foreach ($deployment in $deployments) {
               Remove-TaniumDeployDeployment -ID $deployment.id -Verbose
          }
     }

     if ($Mode -eq 'All' -or $Mode -eq 'Patch') {
          # Tanium Patch Deployments

          $nowTime = Get-Date
          $killTime = $(Get-Date $nowTime -Format 'yyyy-MM-dd HH:mm:ssZ').ToString()

          Get-TaniumPatchDeployments | `
               Where-Object {$_.isActive -eq 'true'} | `
               ForEach-Object {Set-TaniumPatchDeployment -Data @{stoppedAt="$killTime"} -ID $_.id -Verbose}
     }
}