workflow 3-start-vmss-parallel
{ 
    param 
    (    
        [Parameter(Mandatory=$true)][ValidateSet("Start","Stop")] 
        [String] $Action,

        [Parameter(Mandatory=$true)] 
        [String] 
        $TagValue 
    ) 

    ## Authentication
    Write-Output ""
    Write-Output "------------------------ Authentication ------------------------"
    Write-Output "Logging into Azure ..."
    
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
    ## End of authentication

    ## Getting all virtual machines
    Write-Output ""
    Write-Output ""
    Write-Output "---------------------------- Status ----------------------------"
    Write-Output "Getting all VMSS from all resource groups ..."

    try
    {
		if($Action -eq "Start" -and $TagValue -eq "MON_FRI_0845")
		{ 
            Write-Output "--------------------------- Updating ---------------------------"
            Write-Output "Trying to start vmss ..."
    
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