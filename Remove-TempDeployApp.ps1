# Now uses Get-AzureRMWebApp(Slot) and Set-AzureRmWebApp(Slot) to remove Virtual Directory from existing configuration

#Retrieve variables from environment and bail if not set

if (-not $Env:RESOURCEGROUPNAME)
{
	Write-Error ("RESOURCEGROUPNAME environment variable is missing.")
	exit 1
}
elseif (-not $Env:WEBSITENAME)
{
	Write-Error ("WEBSITENAME environment variable is missing.")
	exit 1
}


$resourceGroupName = "$Env:RESOURCEGROUPNAME"
$websiteName = "$Env:WEBSITENAME"
$slotName = if ($env:SLOTNAME) { $env:SLOTNAME } else { "NoSlot" } 
$WebAppApiVersion = "2018-02-01"

Write-Host "Remove a virtual application"

# Retrieve Web App
$website = Get-AzureRmWebApp -Name $env:WEBSITENAME -ResourceGroupName $env:RESOURCEGROUPNAME


if($slotName -eq "NoSlot" )
{
    write-Host "Configuring root web app"
    
    $TempApp = $website.SiteConfig.VirtualApplications |? {$_.VirtualPath -eq "/tempdeploy"}
    $null = $website.SiteConfig.VirtualApplications.Remove($TempApp);
    $website | Set-AzureRmWebApp
    
}
else
{
    write-Host "Configuring deployment slot: $slotName"
    #Retrieve slot from main web app
    $slotsite = Get-AzureRmWebAppSlot -WebApp $website -Slot $slotName
    $TempApp = $slotsite.SiteConfig.VirtualApplications |? {$_.VirtualPath -eq "/tempdeploy"}
    $null = $slotsite.SiteConfig.VirtualApplications.Remove($TempApp)
    $slotsite | Set-AzureRmWebAppSlot
}    
