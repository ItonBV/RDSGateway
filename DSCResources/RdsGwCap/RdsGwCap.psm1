function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory, ParameterSetName='Named')]
		[ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [System.Boolean]
        $Enable,

        [System.Boolean]
        $PasswordAuthentication,

        [System.Boolean]
        $SmartcardAuthentication,

        [System.Boolean]
        $DiskDrivesDisabled,

        [System.Boolean]
        $PlugAndPlayDevicesDisabled,

        [System.Boolean]
        $PrintersDisabled,

        [System.Boolean]
        $SerialPortsDisabled,

        [System.Boolean]
        $ClipboardDisabled,

		[Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserGroupNames,

        [System.UInt32]
        $SessionTimeout,

		[ValidateSet('Present','Absent')]
		[System.String]
        $Ensure
    )

	<#
	if ($PSCmdlet.ParameterSetName -eq 'Named') {
    $QueryParams.Add('Filter',('Name = "{0}"' -f $Name))
    }
	#>

	Write-Verbose "Getting current CAP settings for `"$($Name)`""

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

	$returnValue = @{
		Name = [System.String]
		Enable = [System.Boolean]
		PasswordAuthentication = [System.Boolean]
		SmartcardAuthentication = [System.Boolean]
		DiskDrivesDisabled = [System.Boolean]
		PlugAndPlayDevicesDisabled = [System.Boolean]
		PrintersDisabled = [System.Boolean]
		SerialPortsDisabled = [System.Boolean]
		ClipboardDisabled = [System.Boolean]
		UserGroupNames = [System.String]
		SessionTimeout = [System.UInt32]
		AllowOnlySDRServers = [System.Boolean]
		ComputerGroupNames = [System.String]
		CookieAuthentication = [System.Boolean]
		DeviceRedirectionType = [System.UInt32]
		SecureId = [System.Boolean]
		SessionTimeoutAction = [System.UInt32]
		Ensure = [System.String]
    }

	$Result = Get-RdsGwCap -Name $Name

    If ($Result)
    {
		$returnValue.Name = $Name
		$returnValue.Enable = $Result.Enable
		$returnValue.PasswordAuthentication = $Result.PasswordAuthentication
		$returnValue.SmartcardAuthentication = $Result.SmartcardAuthentication
		$returnValue.DiskDrivesDisabled = $Result.DiskDrivesDisabled
		$returnValue.PlugAndPlayDevicesDisabled = $Result.PlugAndPlayDevicesDisabled
		$returnValue.PrintersDisabled = $Result.PrintersDisabled
		$returnValue.SerialPortsDisabled = $Result.SerialPortsDisabled
		$returnValue.ClipboardDisabled = $Result.ClipboardDisabled
		$returnValue.UserGroupNames = $Result.UserGroupNames
		$returnValue.SessionTimeout = $Result.SessionTimeout
		$returnValue.AllowOnlySDRServers = $Result.AllowOnlySDRServers
		$returnValue.ComputerGroupNames = $Result.ComputerGroupNames
		$returnValue.CookieAuthentication = $Result.CookieAuthentication
		$returnValue.DeviceRedirectionType = $Result.DeviceRedirectionType
		$returnValue.SecureId = $Result.SecureId
		$returnValue.SessionTimeoutAction = $Result.SessionTimeoutAction
		$returnValue.Ensure = 'Present'
	}
	Else
	{
		$returnValue.Name = $Name
		$returnValue.Ensure = 'Absent'
	}

    $returnValue
    #>
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.Boolean]
        $Enable = $true,

        [System.Boolean]
        $PasswordAuthentication = $true,

        [System.Boolean]
        $SmartcardAuthentication = $false,

        [System.Boolean]
        $DiskDrivesDisabled = $false,

        [System.Boolean]
        $PlugAndPlayDevicesDisabled = $false,

        [System.Boolean]
        $PrintersDisabled = $false,

        [System.Boolean]
        $SerialPortsDisabled = $false,

        [System.Boolean]
        $ClipboardDisabled = $false,

		[Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserGroupNames,

        [System.UInt32]
        $SessionTimeout = 0,

		[ValidateSet('Present','Absent')]
		[System.String]
        $Ensure = 'Present'
    )

	#Somehow, only when all options are set to false AND DeviceRedirectionType is set to 2, the AllowOnlySDRServers setting is ingored and set to $true, so correct this behavior
    
	If ((!($DiskDrivesDisabled)) -and (!($PlugAndPlayDevicesDisabled)) -and (!($PrintersDisabled)) -and (!($SerialPortsDisabled)) -and (!($ClipboardDisabled)))
    {
        $DeviceRedirectionType = [uint32]0
    }
    Else
    {
        $DeviceRedirectionType = [uint32]2
    }

    $CapArgs = @{
        AllowOnlySDRServers = $false
        ClipboardDisabled = $ClipboardDisabled
        ComputerGroupNames = [string]::Empty
        CookieAuthentication = $true
        DeviceRedirectionType = $DeviceRedirectionType
        <#
        Specifies which devices will be redirected.
        0 All devices will be redirected.
        1 No devices will be redirected.
        2 Specified devices will not be redirected. The DiskDrivesDisabled, PrintersDisabled, SerialPortsDisabled, ClipboardDisabled, and PlugAndPlayDevicesDisabled properties control which devices will not be redirected.
        #>
        DiskDrivesDisabled  = $DiskDrivesDisabled
        Enabled = $Enable
        #HasNapAttributes = $false
        IdleTimeout = [uint32]0
        Name = $Name
        #Order                       : 1
        Password = $PasswordAuthentication
        PlugAndPlayDevicesDisabled = $PlugAndPlayDevicesDisabled
        PrintersDisabled = $PrintersDisabled
        SecureId = $false
        SerialPortsDisabled = $SerialPortsDisabled
        SessionTimeout  = $SessionTimeout
        SessionTimeoutAction = [uint32]0
        Smartcard = $SmartcardAuthentication
        UserGroupNames = $UserGroupNames
    }

	If ($Ensure -eq 'Present') {
		Write-Verbose "Creating CAP `"$($Name)`"."
		$Invoke = Invoke-CimMethod -Namespace root/CIMV2/TerminalServices -ClassName Win32_TSGatewayConnectionAuthorizationPolicy -MethodName Create -Arguments $CapArgs
		if ($Invoke.ReturnValue -ne 0) {
			throw ('Failed creating CAP Policy. Returnvalue: {0}' -f $Invoke.ReturnValue)
		} 
	}

	
	If ($Ensure -eq 'Absent') {
		Write-Verbose "Deleting CAP `"$($Name)`"."
		$Invoke = Get-CimInstance -Namespace root/CIMV2/TerminalServices -ClassName Win32_TSGatewayConnectionAuthorizationPolicy -Filter ('Name = "{0}"' -f $Name) |  Invoke-CimMethod -MethodName Delete -Confirm:$false
        If ($Invoke.ReturnValue -ne 0) {
            throw ('Failed removing CAP Policy. Returnvalue: {0}' -f $Invoke.ReturnValue)
        }
	}

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

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
        $Name,

        [System.Boolean]
        $Enable,

        [System.Boolean]
        $PasswordAuthentication,

        [System.Boolean]
        $SmartcardAuthentication,

        [System.Boolean]
        $DiskDrivesDisabled,

        [System.Boolean]
        $PlugAndPlayDevicesDisabled,

        [System.Boolean]
        $PrintersDisabled,

        [System.Boolean]
        $SerialPortsDisabled,

        [System.Boolean]
        $ClipboardDisabled,

		[Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserGroupNames,

        [System.UInt32]
        $SessionTimeout,

		[ValidateSet('Present','Absent')]
		[System.String]
        $Ensure = 'Present'
    )

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

	$currentValues = Get-TargetResource @PSBoundParameters
	$Result = [System.Boolean](
		($currentValues.Name -ieq $Name) -and `
		($currentValues.Ensure -ieq $Ensure)
	)
	
	If ($Result) {Write-Verbose "CAP settings for `"$($Name)`" in desired state"}
	Else {Write-Verbose "CAP settings for `"$($Name)`" NOT in desired state"}

	$Result
}

function Remove-RdsGwCap {
    #[cmdletbinding(SupportsShouldProcess, ConfirmImpact='High')]
	[cmdletbinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ciminstance] $RdsGwCap
    )
    if ($PSCmdlet.ShouldProcess($RdsGwCap)) {
        $Invoke = $RdsGwCap | Invoke-CimMethod -MethodName Delete -Confirm:$false
        if ($Invoke.ReturnValue -ne 0) {
            throw ('Failed removing CAP Policy. Returnvalue: {0}' -f $Invoke.ReturnValue)
        }
    }
}

function Get-RdsGwCap {
    [cmdletbinding(DefaultParameterSetName='list')]
    param (
        [Parameter(Mandatory, ParameterSetName='Named')]
        [ValidateNotNullOrEmpty()]
        [string] $Name
    )
    $QueryParams = @{
        Namespace = 'root/CIMV2/TerminalServices'
        ClassName = 'Win32_TSGatewayConnectionAuthorizationPolicy'
    }
    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $QueryParams.Add('Filter',('Name = "{0}"' -f $Name))
    }
    Get-CimInstance @QueryParams
}

Export-ModuleMember -Function *-TargetResource

