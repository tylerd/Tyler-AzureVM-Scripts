Param(
    [string]$resourceGroupName,
    [string]$vmssName,
    [string]$newversion
)

$rg = Get-AzureRmResourceGroup -Name $resourceGroupName

$vmss = $rg | Get-AzureRmVmss -VMScaleSetName $vmssName

$vmss.virtualMachineProfile.storageProfile.imageReference.version = $newversion

$rg | Update-AzureRmVmss -Name $vmssName -VirtualMachineScaleSet $vmss

$instanceIds = ($vmss | Get-AzureRmVmssVM).InstanceId

#Update in odd and even groups
#Odd numbered array indexes
$instanceGroup1 = $instanceIds[(0..($instanceIds.Length - 1) | where {($_ % 2) -ne 0 })] 
#even array indexes
$instanceGroup2 = $instanceIds[(0..($instanceIds.Length - 1) | where {($_ % 2) -eq 0 })] 


#ANOTHER OPTION: Update the first half of the instances
#first half
#$instanceGroup1 = $instanceIds[0..(($instanceIds.Length/2)-1)]
#second half
#$instanceGroup2 = $instanceIds[($instanceIds.Length/2)..($instanceIds.Length)]


Update-AzureRmVmssInstance -ResourceGroupName $vmss.ResourceGroupName -VMScaleSetName $vmss.Name -InstanceId $instanceGroup1
#Note: Powershell cmdlet automatically waits until completion

Update-AzureRmVmssInstance -ResourceGroupName $vmss.ResourceGroupName -VMScaleSetName $vmss.Name -InstanceId $instanceGroup2

