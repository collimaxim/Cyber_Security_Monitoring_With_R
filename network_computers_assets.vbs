

'Create the output file
Dim  strComputer, objFso
strComputer = "."
Set SystemSet = GetObject("winmgmts:" _
   & "{impersonationLevel=impersonate}!\\" _
    & strComputer & "\root\cimv2").InstancesOf ("Win32_ComputerSystem")

	Set objFso = WScript.CreateObject("Scripting.FileSystemObject")
	'Set outputFile = objFso.CreateTextFile("run\"  strComputer & "_Network_Assets", True)
Set outputFile = objFso.CreateTextFile("run\Network_Computer_Assets.txt", True )
'Print header (comment out the line below if you do not want headers in your output file)
outputFile.WriteLine "Domain_Name" & vbTab & "Computer_Name" & vbTab & "User_Name" & vbTab & "DNS_Host_Name" & vbTab & "Computer_Role"  & vbTab & "Manufacturer"  & vbTab & "Model"  & vbTab & "Admin_Password_Status" & vbTab & "Computer_System_Type" & VbCrLf 



for each System in SystemSet
Select Case System.DomainRole 
        Case 0 
            strComputerRole = "Standalone Workstation"
        Case 1        
            strComputerRole = "Member Workstation"
        Case 2
            strComputerRole = "Standalone Server"
        Case 3
            strComputerRole = "Member Server"
        Case 4
            strComputerRole = "Backup Domain Controller"
        Case 5
            strComputerRole = "Primary Domain Controller"
    End Select
	Select Case System.AdminPasswordStatus 
	       Case 1
		   strAdminPWStatus = "Disabled"
		   Case 2 
		      strAdminPWStatus = "Enabled"
		   Case 3
		      strAdminPWStatus =  "Not Implemented"
		   Case 4 
		      strAdminPWStatus =  "Unknown"
	End Select
	Select Case System.PCSystemType
Case 0 
strPCSysType = "Unspecified"
 
Case 1 
strPCSysType = "Desktop"
 
Case 2 
strPCSysType = "Mobile (laptop or tablet)"
 
Case 3 
strPCSysType = "Workstation"
 
Case 4 
strPCSysType = "Enterprise Server"
 
Case 5 
strPCSysType = "Small Office and Home Office (SOHO) Server"
 
Case 6 
strPCSysType = "Appliance PC"
 
Case 7 
strPCSysType = "Case Performance Server"
 
Case 8 
strPCSysType = "Maximum"
End Select 
 
  outputFile.WriteLine System.Domain & vbTab & System.Name & vbTab & System.UserName  & vbTab & System.DNSHostName	 & vbTab & strComputerRole & vbTab & System.Manufacturer & vbTab & System.Model & vbTab & strAdminPWStatus  & vbTab & strPCSysType 
next

'Close the output file vbTab
outputFile.Close

'Clean up and exit
Set objShell = Nothing
Set objFso = Nothing