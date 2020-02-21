function Remove-DrsVmFromDrsVmGroup {
    #Requires -Modules VMware.VimAutomation.Core, DRSRule

    <#
    .SYNOPSIS  
        Removes virtual machines from a DRS VM group based on datastore location
    .DESCRIPTION
        Removes virtual machines from a DRS VM group based on datastore location
    .NOTES
        Version:        2.0.0
        Author:         Tim Carman
        Twitter:        @tpcarman
        Github:         tpcarman
    .LINK
        https://github.com/tpcarman/PowerCLI-Scripts	

    .PARAMETER Cluster
        Specifies the cluster which contains the DRS VM Group
        This parameter is mandatory but does not have a default value.
    .PARAMETER DrsVMGroup
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
        Remove-DrsVmFromDrsVmGroup -Cluster 'Production' -DRSVMGroup 'SiteA-VMs' -Prefix 'SiteA-' 
    .EXAMPLE
        Remove-DrsVmFromDrsVmGroup -Cluster 'Production' -DRSVMGroup 'SiteA-VMs' -Suffix '-02' 
    .EXAMPLE
        Remove-DrsVmFromDrsVmGroup -Cluster 'Production' -DRSVMGroup 'SiteB-VMs' -Datastore 'VMFS-01' 
    #>

    [CmdletBinding()]
    Param(

        [Parameter(
            Position = 0,
            Mandatory = $True,
            HelpMessage = 'Specify the cluster name'
        )]
        [ValidateNotNullOrEmpty()] 
        [String]$Cluster,
        
        [Parameter(
            Position = 1,
            Mandatory = $True,
            HelpMessage = 'Specify the name of the DRS VM Group'
        )]
        [ValidateNotNullOrEmpty()]
        [String]$DrsVMGroup,

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

    if ($Prefix) {
        $VMs = Get-Datastore | Where-Object { ($_.name).StartsWith($Prefix) } | Get-VM | Sort-Object Name
    }
    if ($Datastore) {
        $VMs = Get-Datastore | Where-Object { ($_.name) -eq $Datastore } | Get-VM | Sort-Object Name
    }
    if ($Suffix) {
        $VMs = Get-Datastore | Where-Object { ($_.name).EndsWith($Suffix) } | Get-VM | Sort-Object Name
    }

    $objDrsVMGroup = Get-DrsClusterGroup -Name $DrsVMGroup -Cluster $Cluster -Type VMGroup
    foreach ($VM in $VMs) {
        if (($objDrsVMGroup).Member -contains $VM) {        
            try {
                Write-Host "Removing virtual machine $VM from DRS VM Group $DrsVMGroup"
                $null = Set-DrsClusterGroup -DrsClusterGroup $DrsVMGroup -Remove -VM $VM
            } catch {
                Write-Error "Error removing virtual machine $VM from DRS VM Group $DrsVMGroup"
            } 
        }
    }
}