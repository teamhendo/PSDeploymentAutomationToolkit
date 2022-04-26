function Get-DAAddress {

Begin 
{
     [uri]$URI = $null
}

Process
{
     $URI = Read-Host "Please provide the URI of the Tanium server that you want to connect to.`n`nExample: https://yourTaniumServer.com"
     
     if ($URI.OriginalString -like "*\*")
     {
          $URI = $($URI.OriginalString).Replace('\','/')
     }

     if ($URI.OriginalString -like "http://*")
     {
          $URI = $($URI.OriginalString).Replace('http://','https://')
     }
}

End
{
     Write-Log -Component "New-DAAddress" `
               -Type 2 `
               -LogFile $scriptLogFile `
               -Message "The URI provided from the user was: $URI" 
     
     return $URI
}
}