## IMPORTANT
## This script currently makes assumptions about the target app service.  Running this blindly may result in loss of virtual directory configuration
## The assumption is that before running this script, there is a single virtual application "/" pointing to "site\wwwroot\docroot"
## Always verify these scripts in a testing environment before using in a production capacity


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
