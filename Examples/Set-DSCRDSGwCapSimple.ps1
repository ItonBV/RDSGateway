<#
Param(
	[Parameter(Position=0, HelpMessage='FQDN of the ConnectionBroker for the RDS deployment')]
	[String] $ConnectionBroker = ([System.Net.Dns]::GetHostEntry([string]$env:computername).HostName),
	[Parameter(Position=1, Mandatory=$True, HelpMessage='External FQDN for the remotedesktop gateway')]
	[String] $GatewayExternalFQDN
)
#>

Configuration RDSGWCapConfig
{
    Import-DSCResource -ModuleName RDSGateway

    RdsGwCap RDGCAPConfig
    { 
		Name = 'RDG CAP all' # Policy name to accept all device redirection for this group
		UserGroupNames = "AU_Shared_RDG CAP all" # Group name for which policy aplies
    }
}

$MOFPath = 'C:\Support\MOF'
If (!(Test-Path $MOFPath)){New-Item -Path $MOFPath -ItemType Directory}
RDSGWCapConfig -OutputPath $MOFPath #-ConfigurationData $ConfigData -DomainCred $DomainCred -NodeName $nodename 
Start-DscConfiguration -Path $MOFPath -Computername 'localhost' -Wait -Force -Verbose