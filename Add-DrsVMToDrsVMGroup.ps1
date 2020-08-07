function Add-DrsVmToDrsVmGroup {
    #Requires -Modules @{ ModuleName="VMware.VimAutomation.Core"; ModuleVersion="6.5.1" }

    <#
    .SYNOPSIS  
        Adds virtual machines to a DRS VM group based on datastore location
    .DESCRIPTION
        Adds virtual machines to a DRS VM group based on datastore location
    .NOTES
        Version:        2.1.0
        Author:         Tim Carman
        Twitter:        @tpcarman
        Github:         tpcarman
    .LINK
        https://github.com/tpcarman/PowerCLI-Scripts
    
    .PARAMETER Cluster
        Specifies the cluster which contains the DRS VM Group
        This parameter is mandatory but does not have a default value.
    .PARAMETER DrsVmGroup
        Specifies the DRS VM Group
        This parameter is mandatory but does not have a default value.
    .PARAMETER Prefix
        Specifies a prefix string for the datastore name
        This parameter is optional and does not have a default value.
    .PARAMETER Suffix
        Specifies a suffix string for the datastore name
        This parameter is optional and does not have a default value.
    .PARAMETER Datastore
        Specifies a datastore name
        This parameter is optional and does not have a default value.
    .EXAMPLE
        Add-DrsVmToDrsVmGroup -Cluster 'Production' -DrsVmGroup 'SiteA-VMs' -Prefix 'SiteA-' 
    .EXAMPLE
        Add-DrsVmToDrsVmGroup -Cluster 'Production' -DrsVmGroup 'SiteA-VMs' -Suffix '-02' 
    .EXAMPLE
        Add-DrsVmToDrsVmGroup -Cluster 'Production' -DrsVmGroup 'SiteB-VMs' -Datastore 'VMFS-01'  
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True,
            HelpMessage = 'Specify the cluster name')]
        [ValidateNotNullOrEmpty()] 
        [String]$Cluster,

        [Parameter(
            Position = 1,
            Mandatory = $True, 
            HelpMessage = 'Specify the name of the DRS VM Group'
        )]
        [ValidateNotNullOrEmpty()]
        [String]$DrsVmGroup,

        [Parameter(
            Position = 2,
            Mandatory = $False,
            ParameterSetName = ’Prefix’,
            HelpMessage = 'Specify the prefix string for the datastore name'
        )]
        [ValidateNotNullOrEmpty()]
        [String]$Prefix,

        [Parameter(
            Position = 2,
            Mandatory = $False,
            ParameterSetName = ’Suffix’,
            HelpMessage = 'Specify the suffix string for the datastore name'
        )]
        [ValidateNotNullOrEmpty()]
        [String]$Suffix,
        
        [Parameter(
            Position = 2,
            Mandatory = $False,
            ParameterSetName = ’Datastore’,
            HelpMessage = 'Specify the datastore name'
        )]
        [ValidateNotNullOrEmpty()]
        [String]$Datastore
    )

    Begin {}

    Process {
        if ($Prefix) {
            $VMs = Get-Datastore | Where-Object { ($_.name).StartsWith($Prefix) } | Get-VM | Sort-Object Name
        }
        if ($Datastore) {
            $VMs = Get-Datastore | Where-Object { ($_.name) -eq $Datastore } | Get-VM | Sort-Object Name
        }
        if ($Suffix) {
            $VMs = Get-Datastore | Where-Object { ($_.name).EndsWith($Suffix) } | Get-VM | Sort-Object Name
        }

        $objDrsVmGroup = Get-DrsClusterGroup -Name $DrsVmGroup -Cluster $Cluster -Type VMGroup
        foreach ($VM in $VMs) {
            if (($objDrsVmGroup).Member -notcontains $VM) {
                try {
                    Write-Host "Adding virtual machine $VM to DRS VM Group $DrsVmGroup"
                    $null = Set-DrsClusterGroup -DrsClusterGroup $DrsVmGroup -Add -VM $VM
                } catch {
                    Write-Error "Error adding virtual machine $VM from DRS VM Group $DrsVmGroup"
                } 
            }
        }
    }

    End {}
}