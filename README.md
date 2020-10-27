Azure EA Billing Data Export to CSV
===================================

            

Powershell script to download Azure EA billing data to CSV.


This uses the new API downloading data from the new URL https://consumption.azure.com/v3/enrollments


Credit goes to the script based on the old API found at http://www.redbaronofazure.com/?p=631


Requres 5 mandatory parameters:


-EnrollmentNbr 
Your unique EA enrollment number


-Key
Your API key, obtain from the EA portal. NOTE: These expire every 6 months


-CsvFile
Full path to CSV file to export the data to


-startDate
Use format yyyy-MM-dd (example 2019-01-13)


 -endDate
Use format yyyy-MM-dd (example 2019-01-15)


Please feel free to download, use and modify as you wish, any questions drop them in Q and A.


NOTE: Only tested on Windows Server 2016.


 


 

 

        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
