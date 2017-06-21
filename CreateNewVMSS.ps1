Param(
    [string]$resourceGroupName,
    [string]$location,
    [string]$adminUser,
    [securestring]$adminPassword
)

$rg = New-AzureRmResourceGroup -Location $location -Name $resourceGroupName

# Create a config object
$vmssConfig = New-AzureRmVmssConfig -Location $rg.Location -SkuCapacity 2 -SkuName Standard_A0  -UpgradePolicyMode Manual

$version = "2016.127.20170421"

# Reference a virtual machine image from the gallery
Set-AzureRmVmssStorageProfile $vmssConfig `
    -ImageReferencePublisher MicrosoftWindowsServer `
    -ImageReferenceOffer WindowsServer `
    -ImageReferenceSku 2016-Datacenter `
    -ImageReferenceVersion $version

# Set up information for authenticating with the virtual machine
Set-AzureRmVmssOsProfile $vmssConfig -AdminUsername $adminUser -AdminPassword $adminPassword -ComputerNamePrefix $resourceGroupName

# Create the virtual network resources
$subnet =  New-AzureRmVirtualNetworkSubnetConfig -Name "vmss-subnet" -AddressPrefix 10.0.0.0/24
$vnet = $rg | New-AzureRmVirtualNetwork -Name "$resourceGroupName-VNET" -AddressPrefix 10.0.0.0/16 -Subnet $subnet
$ipConfig = New-AzureRmVmssIpConfig -Name "vmss-ip-address" -LoadBalancerBackendAddressPoolsId $null -SubnetId $vnet.Subnets[0].Id

# Attach the virtual network to the config object
Add-AzureRmVmssNetworkInterfaceConfiguration -VirtualMachineScaleSet $vmssConfig -Name "vmss-network" -Primary $true -IPConfiguration $ipConfig

# Create the scale set with the config object (this step might take a few minutes)
$rg | New-AzureRmVmss -Name "$resourceGroupName-VMSS" -VirtualMachineScaleSet $vmssConfig