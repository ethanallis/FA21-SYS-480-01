# Make sure you establish a connection to your vcenter instance, will try to do it here
Write-Output "Script Beginning"
$choice = Read-Host -Prompt "Please enter your vCenter hostname, or type 'exit' to quit"

if ($choice -match "exit")
{
	Exit
}
else
{
	Connect-VIServer($choice)	
}

Start-Sleep -Seconds 1

Get-VM
$vmchoice = Read-Host -Prompt "Please enter the vm for full clone deploy"
$vm = Get-VM -Name $vmchoice

Start-Sleep -Seconds 1

$snapshot = Get-Snapshot -VM $vm -Name "base"

Start-Sleep -Seconds 1

Get-VMHost
$vmhostchoice = Read-Host -Prompt "Please enter the vm host name"
$vmhost = Get-VMHost -Name $vmhostchoice

Start-Sleep -Seconds 1

Get-Datastore
$dstorechoice = Read-Host -Prompt "Please enter datastore name"
$dstore = Get-Datastore $dstorechoice

Start-Sleep -Seconds 1

$linkedname = "{0}.linked" -f $vm.name
$linkedvm = New-VM -LinkedClone -Name $linkedname -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore

Start-Sleep -Seconds 1

$newvmname = Read-Host -Prompt "Please enter a new VM name"
$newvm = New-VM -Name $newvmname -VM $linkedvm -VMHost $vmhost -Datastore $dstore

Start-Sleep -Seconds 1

$newvm | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName 480-WAN -Confirm:$false

Start-Sleep -Seconds 1

$newvm | new-snapshot -Name "base"

Start-Sleep -Seconds 1

$linkedvm | Remove-VM

Start-Sleep -Seconds 1

Write-Output "Script Complete, Clone Deployed"

Start-Sleep -Seconds 3
Disconnect-VIServer
