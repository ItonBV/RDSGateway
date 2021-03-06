function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ConnectionBroker = ([System.Net.Dns]::GetHostEntry([string]$env:computername).HostName),

		#[parameter(Mandatory = $true)]
        [System.String]
        $GatewayExternalFQDN,

        #[parameter(Mandatory = $true)]
		[ValidateSet('DoNotUse','Custom','Automatic')]
        [System.String]
        $GatewayMode = 'Custom',

        #[parameter(Mandatory = $true)]
        [System.Boolean]
        $UseCachedCredentials = $true,

        #[parameter(Mandatory = $true)]
        [System.Boolean]
        $BypassLocal= $True,

        #[parameter(Mandatory = $true)]
		[ValidateSet('Password','Smartcard','AllowUserToSelectDuringConnection')]
        [System.String]
        $LogonMethod = 'Password'
    )

    Write-Verbose "Checking RD Gateway Configuration."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

    $returnValue = @{
    ConnectionBroker = [System.String]
    GatewayExternalFQDN = [System.String]
    GatewayMode = [System.String]
    UseCachedCredentials = [System.Boolean]
    BypassLocal = [System.Boolean]
    LogonMethod = [System.Boolean]
    }

	#Import-Module RemoteDesktop
	$result = Get-RDDeploymentGatewayConfiguration -ConnectionBroker $ConnectionBroker
	$returnValue.ConnectionBroker =  $ConnectionBroker
	$returnValue.GatewayExternalFQDN = $result.GatewayExternalFQDN
	$returnValue.GatewayMode = $result.GatewayMode
	$returnValue.UseCachedCredentials = $result.UseCachedCredentials
	$returnValue.BypassLocal = $result.BypassLocal
	$returnValue.LogonMethod = $result.LogonMethod

    $returnValue
    
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ConnectionBroker = ([System.Net.Dns]::GetHostEntry([string]$env:computername).HostName),

        #[parameter(Mandatory = $true)]
        [System.String]
        $GatewayExternalFQDN,

        #[parameter(Mandatory = $true)]
		[ValidateSet('DoNotUse','Custom','Automatic')]
        [System.String]
        $GatewayMode = 'Custom',

        #[parameter(Mandatory = $true)]
        [System.Boolean]
        $UseCachedCredentials = $true,

        #[parameter(Mandatory = $true)]
        [System.Boolean]
        $BypassLocal= $True,

        #[parameter(Mandatory = $true)]
		[ValidateSet('Password','Smartcard','AllowUserToSelectDuringConnection')]
        [System.String]
        $LogonMethod = 'Password'
    )

    Write-Verbose "Setting RD Gateway Configuration"

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

	#Import-Module RemoteDesktop
	Set-RDDeploymentGatewayConfiguration @PSBoundParameters -force

    #Include this line if the resource requires a system reboot.
    #$global:DSCMachineStatus = 1


}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ConnectionBroker = ([System.Net.Dns]::GetHostEntry([string]$env:computername).HostName),

        #[parameter(Mandatory = $true)]
        [System.String]
        $GatewayExternalFQDN,

        #[parameter(Mandatory = $true)]
		[ValidateSet('DoNotUse','Custom','Automatic')]
        [System.String]
        $GatewayMode = 'Custom',

        #[parameter(Mandatory = $true)]
        [System.Boolean]
        $UseCachedCredentials = $true,

        #[parameter(Mandatory = $true)]
        [System.Boolean]
        $BypassLocal= $True,

        #[parameter(Mandatory = $true)]
		[ValidateSet('Password','Smartcard','AllowUserToSelectDuringConnection')]
        [System.String]
        $LogonMethod = 'Password'
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

	$currentValues = Get-TargetResource @PSBoundParameters
	(
		($currentValues.ConnectionBroker -ieq $ConnectionBroker) -and `
		($currentValues.GatewayExternalFQDN -ieq $GatewayExternalFQDN) -and `
		($currentValues.GatewayMode -ieq $GatewayMode) -and `
		($currentValues.BypassLocal -ieq $BypassLocal) -and `
		($currentValues.LogonMethod -ieq $LogonMethod)
	)

    <#
    $result = [System.Boolean]
    
    $result
    #>
}


Export-ModuleMember -Function *-TargetResource

