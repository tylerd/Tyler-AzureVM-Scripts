
$rgName = ""
$diskName = ""
$newDiskName = ""
$tempStorageAccountName = ""

$rg = Get-AzureRmResourceGroup -Name $rgName

$grant = Grant-AzureRmDiskAccess -ResourceGroupName $rg.ResourceGroupName -DiskName $diskName -Access Read -DurationInSecond 3600 -ErrorAction Stop

$tempSa = $rg | New-AzureRmStorageAccount -Name $tempStorageAccountName -SkuName Standard_LRS -ErrorAction Stop

New-AzureStorageContainer -Name vhds -Context $sacontext

$sacontext = New-AzureStorageContext -StorageAccountName $tempSa.StorageAccountName -StorageAccountKey ($rg | Get-AzureRmStorageAccountKey -Name $tempSa.StorageAccountName)[0].Value

$copy = Start-AzureStorageBlobCopy -AbsoluteUri $grant.AccessSAS -DestContainer vhds -DestBlob osdisk.vhd -DestContext $sacontext

$copy | Get-AzureStorageBlobCopyState -WaitForComplete

$vhdUri = ($copy.ICloudBlob).Uri.AbsoluteUri

$osdisk2 = New-AzureRmDisk -DiskName $newDiskName -Disk (New-AzureRmDiskConfig -AccountType StandardLRS -Location $rg.Location -CreateOption Import -SourceUri $vhdUri) -ResourceGroupName $rg.ResourceGroupName
