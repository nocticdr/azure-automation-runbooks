# Azure Automation for cost saving
Powershell runbooks for Azure automation

Credit to Farouk Friha for the original script.

https://gallery.technet.microsoft.com/scriptcenter/Stop-Start-all-or-only-8a7e11a2

The original script combines both start-stop actions in one script. I split both into two separate files so as not to confuse the users of the script. I end up with one file which starts resources and another one which stops them, based on tags, in parallel.

The only thing users will need to do is to key in the time they want the script to run, in the format below:

### Start script:
MON_FRI_0800 (Check and stop the resource every Monday to Friday at 8AM).

### Stop script:
MON_SUN_2000 (Check and stop the resource every day at 8PM - this is useful if someone starts it manually during the weekend and forgets to shut it down).

-------------------
## Additional Information

### Parallel
In addition to the above, the script will start or stop the resources in parallel and not consecutively. This ensures that resources are available quickly at a specific time. If there are resources which have a dependency on each other, you will need to add specific schedules for the script to start your resources accordingly. 

E.g. A database server could have a tag of MON_FRI_0800 for it to turn on at 08:00AM and an dependent application server could have a tag of MON_FRI_0830 for it to turn on at 08:30AM. Same logic applies when shutting down resources.

### Background Job
Very often there are issues with Azure taking longer than usual to start or stop VMs. This causes the script to run for a longer time, consuming a lot of job minutes. Because of this, I've added an -AsJob parameter when starting or stopping the resources so as to run the task as a background job. 
Pros: Script executes quick and doesn't hang.
Cons: You do not have confirmation within the job's output that resources has started or stopped, although this has not been an issue for me.



@nocticdr|2020
