workflow rb-stop-vmss
{
    param 
    (    
        [Parameter(Mandatory=$true)][ValidateSet("Start","Stop")] 
        [String] $Action,

        [Parameter(Mandatory=$true)] 
        [String] 
        $TagValue 

    ) 
    
   $connectionName = "AzureRunAsConnection"
    try
    {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

        "Logging in to Azure..."
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }
    catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }


    try
    {
		if($Action -eq "Stop" -and $TagValue -eq "MON_SUN_2000") #check if value is equal to tag, if equal shutdown
		{ 
			foreach ($rgname in (Get-AzureRmVmss | ? {$_.Tags["StopSchedule"] -eq "MON_SUN_2000"}))
			{ 
                Write-Output "Stopping VMSS '$($rgname.Name)'"; 
				Stop-AzureRmVmss -ResourceGroupName $rgname.ResourceGroupName -VMScaleSetName $rgname.Name -Force -Verbose 
				Write-Output "Successfully stopped '$($rgname.Name)' VMSS in '$($rgname.ResourceGroupName)' resource group"; 
			} 
		}
       
        if ($Action -eq "Stop" -and $TagValue -eq "MON_SUN_2200")
        {
            foreach ($rgname in (Get-AzureRmVmss | ? {$_.Tags["StopSchedule"] -eq "MON_SUN_2200"}))
			{ 
                Write-Output "Stopping VMSS '$($rgname.Name)'"; 
			    Stop-AzureRmVmss -ResourceGroupName $rgname.ResourceGroupName -VMScaleSetName $rgname.Name -Force -Verbose
				Write-Output "Successfully stopped '$($rgname.Name)' VMSS in '$($rgname.ResourceGroupName)' resource group"; 
			} 
        }

	}
    catch
    {
        Write-Error -Message $_.Exception
            throw $_.Exception    
    }

}