$rgName = ""
$newVmName = ""
$newVmSize = ""

$nicName = ""
$osDiskName = ""

$rg = Get-AzureRmResourceGroup -Name $rgName

$osDisk = $rg | Get-AzureRmDisk -DiskName $osDiskName
$nic = $rg | Get-AzureRmNetworkInterface -Name $nicName

$vmconfig = New-AzureRmVMConfig -VMName $newVmName -VMSize $newVmSize 

$vmconfig | Add-AzureRmVMNetworkInterface -Id $nic.Id

$vmconfig | Set-AzureRmVMOSDisk -ManagedDiskId $osDisk.Id -Name $osDisk.Name -CreateOption Attach -Windows

$rg | New-AzureRmVM -VM $vmconfig