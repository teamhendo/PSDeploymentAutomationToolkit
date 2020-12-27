function Set-JSONProperty
{
    [CmdletBinding()]
    Param (
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [Parameter(Mandatory=$true)]
    [string]$NoteProperty,
    [Parameter(Mandatory=$true)]
    [string]$Value
    )
    try
    {
        $catalogItemContent = Get-Content $Path -Raw | Out-String | ConvertFrom-Json

        $catalogItemContent | Add-Member -NotePropertyName "$NoteProperty" -NotePropertyValue "$Value" -Force

		Start-Sleep -Seconds 1

        $catalogItemContent | ConvertTo-Json | Out-File "$Path" -Force
    }
    catch [System.Management.Automation.ParameterBindingValidationException]
    {
        Write-Host "Catalog path not found - $scriptDirectory/DeploymentAutomationFramework/dependencies/catalog/$($job.frameworkCatalogName)"
    }
    catch [System.Net.WebException],[System.Exception]
    {
        Write-Host "Other exception"
    }
}