
##################################################################################################################					
#					Author : Rupesh Kolatwar                                                 #              
#                                                                                                                #
#					Usage  :  Remove Snapshot of Virtual machine                             #
##################################################################################################################

#Stop an error from occurring when a transcript is already stopped
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
# 
#Reset the error level before starting the transcript
$ErrorActionPreference="Continue"
Start-Transcript -path C:\Users\User_snapshot\scripting\FinalDoc\Old-Snapshot-output.log -append
# 
#Add the VMWare Snap-in
Add-PSSnapin -Name VMWare.VimAutomation.Core
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Import-Module VMware.VimAutomation.Core
# 
#Get the Credentials
$creds = Get-VICredentialStoreItem -file "C:\Users\User_snapshot\scripting\In.CredsTheFile\In.Creds"
#Connect to the server using the credentials file
Connect-VIServer -Server $creds.host -User $creds.User -Password $creds.Password
#
#will Clear the content of file if previous data if already exists.
#
$CleanCont = Clear-Content -path "C:\Users\User_snapshot\scripting\FinalDoc\Validate.csv"
$CleanCont
#
#Open file and append list of vms for get the snapshot details
$vmList = Get-Content "C:\Users\User_snapshot\scripting\FinalDoc\vmlist.txt"
#get output of existing snapshot if available

  $GetSNPDetails = @("VM","Name","Description","Created","id")

  foreach ( $VmName in $vmList) { Get-Snapshot -VM $VmName |select $GetSNPDetails | out-file -Append -FilePath  'C:\Users\User_snapshot\scripting\FinalDoc\Validate.csv';
                                    
         $GetContent = "C:\Users\User_snapshot\scripting\FinalDoc\Validate.csv";

                if (Test-path $GetContent) {

                        if ((get-item $GetContent).length -gt 0kb) {

                                write-host ("Snapshot is already Exist...!!!Snapshot will be remove  For VM: Name: $VmName")
							
                                        Get-Snapshot -VM $VmName |Remove-Snapshot -Confirm:$false }
                            
                                                else { Echo  ("No Snapshot is available for VM-Name: $VmName")  }

}
                
   }

#Clean Up
Disconnect-VIServer -Force -Confirm:$false
Remove-PSSnapin -Name VMWare.VimAutomation.Core
Stop-Transcript
