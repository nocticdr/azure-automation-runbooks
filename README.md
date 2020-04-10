# Azure Automation for cost saving
Powershell runbooks for Azure automation

Original script by Farouk Friha. 

https://gallery.technet.microsoft.com/scriptcenter/Stop-Start-all-or-only-8a7e11a2

The original script combines both start-stop actions in one script. I split both into two separate files so as not to confuse the users of the script. I end up with one file which starts resources and another one which stops them.

The only thing users will need to do is to key in the time they want the script to run, in the format below:

## Start script:
MON_FRI_0800 (Check and stop the resource every Monday to Friday at 8AM).

## Stop script:
MON_SUN_2000 (Check and stop the resource every day at 8PM - this is useful if someone starts it manually during the weekend and forgets to shut it down).

## Parallel
In addition to the above, the script will start or stop the resources in parallel and not consecutively. 

## Background Job
Very often there are issues with Azure taking longer than usual to start or stop VMs. This causes the script to run for a longer time, consuming a lot of job minutes. Because of this, I've added an -AsJob parameter when starting or stopping the resources so as to run the task as a background job. 
Pros: Script executes quick and doesn't hang.
Cons: You do not have confirmation within the job's output that resources has started or stopped, although this has not been an issue for me.



