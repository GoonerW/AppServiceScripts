# Now uses Get-AzureRMWebApp(Slot) and Set-AzureRmWebApp(Slot) to add Virtual Directory to existing configuration

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

Write-Host "Set a virtual application"

# Retrieve Web App
$website = Get-AzureRmWebApp -Name $env:WEBSITENAME -ResourceGroupName $env:RESOURCEGROUPNAME

# Create new Virtual Application object and configure path
$VirtualApp = New-Object Microsoft.Azure.Management.WebSites.Models.VirtualApplication
$VirtualApp.VirtualPath = "/tempdeploy" 
$VirtualApp.PhysicalPath = "site\wwwroot" 

if($slotName -eq "NoSlot" )
{
    write-Host "Configuring root web app"
    
    $website.SiteConfig.VirtualApplications.Add($virtualApp);
    $website | Set-AzureRmWebApp
    
}
else
{
    write-Host "Configuring deployment slot: $slotName"
    #Retrieve slot from main web app
    $slotsite = Get-AzureRmWebAppSlot -WebApp $website -Slot $slotName
    $slotsite.SiteConfig.VirtualApplications.Add($virtualApp);
    $slotsite | Set-AzureRmWebAppSlot
}    
