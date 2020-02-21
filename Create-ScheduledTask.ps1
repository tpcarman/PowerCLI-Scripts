#Requires -RunAsAdministrator

#region script help
<#

.SYNOPSIS
    Creates a Windows Scheduled Task to run a PowerShell script on startup
.DESCRIPTION
    Creates a Windows Scheduled Task to run a PowerShell script on startup
.NOTES 
    Version:  1.1
    Author:   Tim Carman
    Twitter:  @tpcarman
    Github:   tpcarman
.LINK
    https://github.com/tpcarman/PowerCLI-Scripts
.PARAMETER TaskName
    Specifies the name for the Scheduled Task.
    This parameter is mandatory but does not have a default value.
.PARAMETER FilePath
    Specifies the file path to the PowerShell script.
    This parameter is mandatory but does not have a default value.
.PARAMETER UserId
    Specifies the UserId which is configured to run the Scheduled Task.
    This parameter is not mandatory.
    The Windows SYSTEM account will be used by default.
.EXAMPLE
    .\Create-ScheduledTask.ps1 -TaskName "Install VMware Tools" -FilePath C:\Scripts\Install-VMTools.ps1 
    Creates a Windows Scheduled Task named "Install VMware Tools".
    Sets the task to run the C:\Scripts\Install-VMTools.ps1 script at startup.
    Sets the task to use the Windows SYSTEM account to run the script.
.EXAMPLE
    .\Create-ScheduledTask.ps1 -TaskName "Install VMware Tools" -FilePath C:\Scripts\Install-VMTools.ps1 -UserId DOMAIN\UserName
    Creates a Windows Scheduled Task named "Install VMware Tools".
    Sets the task to run the C:\Scripts\Install-VMTools.ps1 script at startup.
    Sets the task to use the DOMAIN\UserName account to run the task.

#>
#endregion script help

#region script changelog
<# 

.VERSION 1.1 - 20/04/2016
 
 - Added script parameters and regions
 - Improved error handling
 - Added changelog

.VERSION 1.0 - 27/10/2015
              
 - Initial script development

#>
#endregion script changelog

#region script parameters
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,HelpMessage='Please provide a name for the scheduled task')]
    [ValidateNotNullOrEmpty()]
    [String]$TaskName='',

    [Parameter(Mandatory=$true,HelpMessage='Please provide the file path to the PowerShell script')]
    [ValidateNotNullOrEmpty()]
    [String]$FilePath='',

    [Parameter(Mandatory=$false,HelpMessage='Please provide the user account to run the task')]
    [ValidateNotNullOrEmpty()]
    [String]$UserId='SYSTEM'

)
#endregion script parameters

#region script body
if(!(Test-Path $FilePath)){
    Write-Error "Could not locate script '$FilePath'"
    exit
}

if(Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue){
    Write-Error "Scheduled Task '$TaskName' already exists"
    exit   
}
else {
    $Action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-file $FilePath -ExecutionPolicy Unrestricted"
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    $Principal = New-ScheduledTaskPrincipal -UserId $UserID -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal
}
#endregion script body
