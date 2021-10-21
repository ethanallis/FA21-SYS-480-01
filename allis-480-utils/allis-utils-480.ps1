"""
Author: Ethan Allis
Class: SEC-480-01
Assignment: PowerCLI & 480-Utils
Note: This is for educational use only and should only be used as such.
"""

#User Menu Function
Function UserMenu{
    $mainuserchoice = Read-Host -Prompt "
    `nPowerCLI Deploy Script. Options Below.
    `n1. Full Clone Deploy
    `n2. Linked Clone Deploy
    `n3. Exit
    `nPlease enter a number"

    switch($mainuserchoice){
        1{}
        2{}
        3{Exit}
    }
}

Function VIserver{
    $subuserchoice = Read-Host -Prompt "Please enter your vCenter hostname, or type 'exit' to quit"

    if ($choice -match "exit")
    {
	    Exit
    }
    else
    {
	    Connect-VIServer($subuserchoice)	
    }
}

# Full Clone Deploy Function
Function FullClone{
    Write-Host "Deploying full clone. User input required."
    Start-Sleep -Seconds 1

    Get-VM -Location "BASE-VMs"
    $vmchoice = Read-Host -Prompt "Please enter the VM for full clone deploy"
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
}

# LINKED CLONE DEPLOY

Write-Host "Beginning Deployment..."
Start-Sleep -Seconds 2
Write-Host "Deploying..."
$base_vm = Get-VM -Name centos7-BASE
Start-Sleep -Seconds 1
$snapshot = Get-Snapshot -VM $base_vm -Name "base"
Start-Sleep -Seconds 1
$vmhost = Get-VMHost -Name super11.cyber.local
Start-Sleep -Seconds 1
$dstore = Get-Datastore datastore2-super11
Start-Sleep -Seconds 1
$newvm = New-VM -Name "centos-capture-target" -VM $base_vm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore
Start-Sleep -Seconds 1
$newvm | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName 480-WAN -Confirm:$false
Write-Host "Completed Deployment..."

# SCRIPT END