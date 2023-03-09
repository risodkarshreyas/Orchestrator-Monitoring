<#
    .SYNOPSIS
    Check the Orchestrator health in stepwise manner and report any identified issues or anomolies for support troubleshooting.

    .DESCRIPTION
	1. Infra Checks 
		a. Verify that Web Server node(s) are up and accessible via client user/bot machine(s).
		b. DB server node down/not accessible via UiPath web server machines.
		c. For applicable scenarios, HAA (Redis) web server node/service down or not accessible via UiPath web server machines.
	
	2. Description
		a. Verification of IIS Service down on Web server node(s)
		
	.PARAMETER Help
    Option to display the help for a specific invocation command or option.
	[CmdletBinding(DefaultParameterSetName = "Help")]
	[Parameter(Mandatory = $false, ParameterSetName = "Help")]
    [switch]$Help,
	Data Source=LAPTOP-2UEU0KDI\MSSQLSERVER03;Initial Catalog=UiPath;User ID=uipath_sql;Password=uipath_sql
	Verify-OnPrem_Orch_Health -hostname $hostname -port $port -ipaddress $ipaddress 
	$message = Test-NetConnection -ComputerName $ipaddress -Port 443
	.\Orchestrator_OnPrem_Monitoring.ps1 -"LAPTOP-2UEU0KDI" -443 -192.168.1.6 -"LAPTOP-2UEU0KDI\MSSQLSERVER03"
#>
param(
		
		[Parameter(Mandatory = $true, Position = 1)]
        [string] $hostname,

        [Parameter(Mandatory = $true, Position = 2)]
        [string] $port ,

        [Parameter(Mandatory = $true, Position = 3)]
        [string] $ipaddress,
		
		[Parameter(Mandatory = $true, Position = 4)]
        [string] $sqlservername,
		
		[string] $exportLocation,
		[string] $message
		
)

function Main {
	try {
			
			Verify-OnPrem_Orch_Health -hostname $hostname -port $port -ipaddress $ipaddress -sqlservername $sqlservername
	}
        catch {
            Write-Host "Erorr: $_" -ForegroundColor Red
        }
}

function Verify-OnPrem_Orch_Health{
	
		
		param(
			[Parameter(Mandatory = $true, Position = 1)]
			[string] $hostname,

			[Parameter(Mandatory = $true, Position = 2)]
			[string] $port ,

			[Parameter(Mandatory = $true, Position = 3)]
			[string] $ipaddress,
			
			[Parameter(Mandatory = $true, Position = 4)]
			[string] $sqlservername
		)
		
		try {
		
		########## WEB SERVER CONNECTIVITY CHECK##########
		Write-Host "Initializing Web server connectivity............" 
		Test-NetConnection -ComputerName $ipaddress -Port 443
		#$message += Test-NetConnection -ComputerName $ipaddress -Port 443
		
		
		########## SQL SERVER CONNECTIVITY CHECK##########
		Write-Host "Initializing SQL server connectivity............"
		Test-NetConnection -ComputerName $sqlservername -Port 1433
		#$message += Test-NetConnection -ComputerName $sqlservername -Port 1433
		
		########## IIS WEB SERVER CHECK##########
		Write-Host "Initializing IIS checks on ............" + $hostname
		$iis = Get-WmiObject Win32_Service -Filter "Name = 'sample'" -ComputerName $hostname
		
		if ($iis.State -eq 'Running') 
		{ Write-Host "IIS is running on $server" }
		Else 
		{ Write-Host "IIS is NOT running on $server" -ForegroundColor Red }
			
		
		########## WEB SERVER APP POOL CHECK##########
		Write-Host "Initializing App pool checks on ............" + $hostname
		Write-Host "`nScript executed by $env:username for $(Get-Date -f ""MM-dd-yyyy hh:mm:ss"")"
		Write-Host "`nWeb Health Check for $(hostname)"
		Write-Host "-------------------------------------`n"

		Write-Host "IIS Services"
		Write-Host "-------------"
		Write-Host "IIS Admin Service ( IISADMIN ) - "$(Get-Service -Name "IISADMIN" | Select -ExpandProperty Status)
		Write-Host "Windows Process Activation Service ( WAS ) - "$(Get-Service -Name "WAS" | Select -ExpandProperty Status)
		Write-Host "World Wide Web Publishing Service ( W3SVC ) - "$(Get-Service -Name "W3SVC" | Select -ExpandProperty Status)

		"`n"

		$siteList = c:\windows\system32\inetsrv\appcmd.exe list sites
		$appList = c:\windows\system32\inetsrv\appcmd.exe list apppools

		Write-Host "Site Status"
		Write-Host "--------------"
		foreach ($site in $siteList)
		{
			Write-Host $site
		}

		"`n"

		Write-Host "Apppool Status"
		Write-Host "--------------"
		foreach ($app in $appList)
		{
			Write-Host $app
		}
		"`n"
		
		
		################ Storage location check ###############
		#Get-CimInstance -ComputerName LAPTOP-2UEU0KDI win32_logicaldisk | where caption -eq "C:" | foreach-object {write " $($_.caption) $('{0:N2}' -f ($_.Size/1gb)) GB total, $('{0:N2}' -f ($_.FreeSpace/1gb)) GB free "}
	}
	catch {
            Write-Host "Erorr: $_" -ForegroundColor Red
        }
}

Main