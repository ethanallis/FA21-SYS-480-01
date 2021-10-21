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
        1{FullClone}
        2{LinkedClone}
        3{$global:continue = $false}
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

    #User Input and Variable Definitions
    Get-VM -Location BASE-VMs | Select -ExpandProperty Name 
    $vmchoice = Read-Host -Prompt "Please enter the VM for full clone deploy"
    $vm = Get-VM -Name $vmchoice
    Start-Sleep -Seconds 1

    $snapshot = Get-Snapshot -VM $vm -Name "base"
    Start-Sleep -Seconds 1

    Get-VMHost | Select -ExpandProperty Name 
    $vmhostchoice = Read-Host -Prompt "Please enter the vm host name"
    $vmhost = Get-VMHost -Name $vmhostchoice
    Start-Sleep -Seconds 1

    Get-Datastore | Select -ExpandProperty Name 
    $dstorechoice = Read-Host -Prompt "Please enter datastore name"
    $dstore = Get-Datastore $dstorechoice
    Start-Sleep -Seconds 1

    #Linked Clone Creation
    $linkedname = "{0}.linked" -f $vm.name
    $linkedvm = New-VM -LinkedClone -Name $linkedname -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore
    Start-Sleep -Seconds 1

    #Full Clone Creation
    $newvmname = Read-Host -Prompt "Please enter a new VM name"
    $newvm = New-VM -Name $newvmname -VM $linkedvm -VMHost $vmhost -Datastore $dstore
    Start-Sleep -Seconds 1

    #Network Adapter Change
    $newvm | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName 480-WAN -Confirm:$false
    Start-Sleep -Seconds 1

    #Base Snapshot Creation
    $newvm | new-snapshot -Name "base"
    Start-Sleep -Seconds 1

    #Linked Clone Deletion
    $linkedvm | Remove-VM
    Start-Sleep -Seconds 1

    Write-Output "Success! Full clone deployed."
    Start-Sleep -Seconds 3
}

# Linked Clone Deploy Function
Function LinkedClone{
    Write-Host "Deploying linked clone. User input required."
    Start-Sleep -Seconds 1

    #User Input and Variable Definitions
    Get-VM -Location BASE-VMs | Select -ExpandProperty Name 
    $vmchoice = Read-Host -Prompt "Please enter the VM for linked clone deploy"
    $vm = Get-VM -Name $vmchoice
    Start-Sleep -Seconds 1

    $snapshot = Get-Snapshot -VM $vm -Name "base"
    Start-Sleep -Seconds 1

    Get-VMHost | Select -ExpandProperty Name 
    $vmhostchoice = Read-Host -Prompt "Please enter the vm host name"
    $vmhost = Get-VMHost -Name $vmhostchoice
    Start-Sleep -Seconds 1

    Get-Datastore | Select -ExpandProperty Name 
    $dstorechoice = Read-Host -Prompt "Please enter datastore name"
    $dstore = Get-Datastore $dstorechoice
    Start-Sleep -Seconds 1

    #Linked Clone Creation
    $linkedname = Read-Host -Prompt "Please enter a new VM name"
    $linkedvm = New-VM -LinkedClone -Name $linkedname -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore
    Start-Sleep -Seconds 1

    #Network Adapter Change
    $linkedvm | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName 480-WAN -Confirm:$false
    Start-Sleep -Seconds 1

    Write-Output "Success! Linked clone deployed."
    Start-Sleep -Seconds 3
}

#Calling Functions and Sciprt Execution
VIserver

$continue = $true
while ($continue) {
    clear
    UserMenu
}

#Disconnecting From Server
Write-Host "Please disconnect for vCenter below:"
Disconnect-VIServer

#End Script
Exit