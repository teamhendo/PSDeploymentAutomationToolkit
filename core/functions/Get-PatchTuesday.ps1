function Get-PatchTuesday
{
<#  
  .SYNOPSIS   
	Determine the Patch Tuesday for the current month/year or a given month/year passed via the available parameters.
	.PARAMETER Month 
	The month of interest.
	.PARAMETER Year
	The year of interest.
    .EXAMPLE  
	Get-PatchTuesday
    .EXAMPLE  
	Get-PatchTuesday -Month 1 -Year 2021
	.EXAMPLE  
	Get-PatchTuesday January 2021
#>	
	
	param (
		[string]$Month = ((Get-Date).Month),
		[string]$Year = (Get-Date).Year
	)
	
	$firstDayOfMonth = [datetime]$([string]$Month + "/1/" + [string]$Year)
	
	(0..30 | ForEach-Object { $firstDayOfMonth.adddays($_) } | Where-Object { $_.dayOfWeek -eq "Tuesday" })[1]
	
}