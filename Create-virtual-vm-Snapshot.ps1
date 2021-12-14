##################################################################################################################					
#					Author : Rupesh Kolatwar                                                 #
#														 #									
#                                                                                                                #
#					Usage  : Create Snapshot of Virtual machine                              #
##################################################################################################################

#Stop an error from occurring when a transcript is already stopped
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
#
#Reset the error level before starting the transcript
$ErrorActionPreference="Continue"
Start-Transcript -path C:\Users\User_snapshot\scripting\FinalDoc\New-Snapshot-output.log -append
#
#Importing PowerCli Module
#Add the VMWare Snap-in
Add-PSSnapin -Name VMWare.VimAutomation.Core
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Disconnect-VIServer -Force -Confirm:$false
##
#Get the Credentials

#$creds = Get-VICredentialStoreItem -file "C:\Users\User_snapshot\MyVcCred\E1pasword"

$creds = Get-VICredentialStoreItem -file "C:\Users\User_snapshot\scripting\In.CredsTheFile\In.Creds"

#Connect to the VCENTER-SERVER  using the credentials file

Connect-VIServer -Server $creds.host -User $creds.User -Password $creds.Password
#
#Clear the content of file if privous data is exists 
Clear-Content "C:\Users\User_snapshot\scripting\FinalDoc\Validate.csv"
#
#Open file and append list of vms for get the snapshot details
$vmList = Get-Content "C:\Users\User_snapshot\scripting\FinalDoc\vmlist.txt"
#
#get output of existing snapshot Property  if available 
$GetSNPDetails = @("VM","Name","Description","Created","id")

	foreach( $VMName in $vmList) { 
    
	 $VM = Get-Vm -Name $VMName |select -Property Name
#Check the VM "ProvisionedSpaceGB"
     $VMDCheck = Get-Vm -Name $VMName
#Check the "FreeSpaceGB" in Datastore for respective VM
	 $VMDataStore = $VMDCheck | Get-Datastore
#Get the existing snapshot details                                                         
        Get-vm  $VMName | Get-Snapshot |select $GetSNPDetails | out-file -Append -FilePath  'C:\Users\User_snapshot\scripting\FinalDoc\Validate.csv';
                                            
#The script will write existing snapshot details to "Validate.csv"
		if(Get-Snapshot -VM $VMName |select{$_.Id}) { write-host ("Snapshot is already Exist For VM-Name: $VMName") -ForegroundColor red }

                elseIF ($VMDataStore.FreeSpaceGB -gt $VMDCheck.ProvisionedSpaceGB) { 

                        write-host ("Creating New Snapshot--####################### $VMName") 

                 Get-vm -Name $VMName | New-Snapshot -Name "Before Patch"  -Description  "by ruepsh" -Memory:$false -Quiesce:$false -Confirm:$false
		                                                                                                         }
                             else { Write-Host ("No Space available in datastore for VM-Name $VMDCheck") -ForegroundColor red  }
			
			

   }      
                                     
#Clean Up
Disconnect-VIServer -Force -Confirm:$false
Remove-PSSnapin -Name VMWare.VimAutomation.Core
Stop-Transcript
