workflow rb-start-vmss
{ 
    param 
    (    
        [Parameter(Mandatory=$true)][ValidateSet("Start","Stop")] 
        [String] $Action,

        [Parameter(Mandatory=$true)] 
        [String] 
        $TagValue 

    ) 
    
    try
    {
        $Conn = Get-AutomationConnection -Name AzureRunAsConnection
        
        $null = Connect-AzureRMAccount `
                        -ServicePrincipal `
                        -Tenant $Conn.TenantID `
                        -ApplicationId $Conn.ApplicationID `
                        -CertificateThumbprint $Conn.CertificateThumbprint

        Write-Output "Successfully logged into Azure." 
    } 
    catch
    {
        if (!$Conn)
        {
            $ErrorMessage = "Service principal not found."
            throw $ErrorMessage
        } 
        else
        {
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }


    try
    {
		if($Action -eq "Start" -and $TagValue -eq "MON_FRI_0845")
		{ 
			foreach ($rgname in (Get-AzureRmVmss | ? {$_.Tags["StartSchedule"] -eq "MON_FRI_0845"}))
			{ 
                Write-Output "Starting '$($rgname)' resource group"; 
				Start-AzureRmVmss -ResourceGroupName $rgname.ResourceGroupName -VMScaleSetName $rgname.Name -Verbose 
				Write-Output "Successfully started '$($rgname.Name)' VMSS in '$($rgname.ResourceGroupName)' resource group"; 
			} 
		}
       
       
	}
    catch
    {
        Write-Error -Message $_.Exception
            throw $_.Exception    
    }

}