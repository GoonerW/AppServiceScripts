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
# Example call: SetWebAppConfig MyResourceGroup MySite $ConfigObject
Function SetWebAppConfig($ResourceGroupName, $websiteName, $slotName, $ConfigObject)
{
    if($slotName -eq "NoSlot" )
    {
        write-Host "Configuring root web app"
        Set-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/Config -Name $websiteName/web -PropertyObject $ConfigObject -ApiVersion $WebAppApiVersion -Force
    }
    else
    {
        write-Host "Configuring deployment slot: $slotName"
        Set-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/slots/Config -Name $websiteName/$slotName/web -PropertyObject $ConfigObject -ApiVersion $WebAppApiVersion -Force
    }    
}
Write-Host "Set a virtual application"
$props=@{
    virtualApplications = @(
        @{ virtualPath = "/"; physicalPath = "site\wwwroot\docroot" },
        @{ virtualPath = "/tempdeploy"; physicalPath = "site\wwwroot" }
    )
}
SetWebAppConfig $ResourceGroupName $websiteName $slotName $props