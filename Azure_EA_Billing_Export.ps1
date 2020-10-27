#/////////////////////////////////////////////////
#// Script Name: Azure_EA_Billing_Export.ps1
#// Author: Ian Kennon
#// Credits: Based on the original excellent script http://www.redbaronofazure.com/?p=631, which used the now depreciated API
#//
#// Script Usage:
#//	To create export EA billing data to CSV
#//	Pass all mandatory parameters:
#//		-EnrollmentNbr	-	Your unique EA enrollment number
#//		-Key		-	You API key, obtain from the EA portal. NOTE: These expire every 6 months
#//		-CsvFile	-	Full path to CSV file to export the data to
#//		-startDate	-	Use format yyyy-MM-dd (example 2019-01-13)
#//		-endDate	-	Use format yyyy-MM-dd (example 2019-01-15)
#//	Optional - Remove unwanted columns from data by editing where indicated in the script below
#//
#// Script Dependencies:
#//	Valid Azure EA enrollment number and API key
#//
#// Script Version History:
#//	v0.1	15 Jan 2019	First revision
#//
#//////////////////////////////////////////////////////

#// Start of Script
#// Get Parameters
Param(
	[Parameter(Mandatory=$true)]
	[string]$EnrollmentNbr,
	[Parameter(Mandatory=$true)]
	[string]$Key,
	[Parameter(Mandatory=$true)]
	[string]$CsvFile,
	[Parameter(Mandatory=$true)]
	[string]$startDate,
	[Parameter(Mandatory=$true)]
	[string]$endDate
)

#// Set variables
$AccessToken = "Bearer $Key"
$urlbase = 'https://consumption.azure.com/v3/enrollments'

#// function to invoke the api, download the data, import it, and merge it to the global array
Function DownloadUsageReport( [string]$LinkToDownloadDetailReport, $csvAll ) {
	$webClient = New-Object System.Net.WebClient
	$webClient.Headers.add('Authorization', "$AccessToken")
	$data = $webClient.DownloadString("$urlbase/$LinkToDownloadDetailReport")
	$csvAll = $data
	return $csvAll
}

#// Get new data
Write-Output "INFO: Downloading usage data for date: $StartDate to: $EndDate"
$csvAll = DownloadUsageReport "/$EnrollmentNbr/usagedetails/download?startTime=$StartDate&endTime=$endDate" $csvAll

#// Check data returned
if (!$csvAll) {
	Write-Output "ERROR: No data found"
	Exit
}

#// Remove top of result for CSV format
$NewData = "AccountId,"+($csvAll -split "AccountId," | Select -Last 1)

#// Convert from CSV into an ps variable
$csvAll = ($NewData | ConvertFrom-CSV)

#// Show the number of rows found
Write-Output "INFO: Total Rows Found = $($csvAll.length)"

#// Optional - Remove unwanted columns here if required. Uncomment and amend properties to exclude
#// Remove unwanted columns from data
#Write-Output "INFO: Removing unwanted columns from data"
#$csvAll = $csvAll | Select-Object -Property * -ExcludeProperty 'AccountId', 'AccountName', 'AccountOwnerEmail', 'AdditionalInfo', 'Consumed ServiceId', 'CostCenter', 'DepartmentId', 'DepartmentName', 'ExtendedCostCenter', 'ProductId', 'Resource LocationId', 'ServiceAdministratorId', 'ServiceInfo1', 'ServiceInfo2', 'StoreServiceIdentifier', 'SubscriptionId', 'PartNumber', 'ResourceGuid', 'OfferId', 'ChargesBilledSeparately', 'Location', 'ServiceName', 'ServiceTier'

Write-Output "INFO: Processing data, please wait..."
#// Set progress bar variables 
$a=0
$tot = $csvAll.length

for ($i=0; $i -lt $csvAll.length; $i++) {
	#// Set up progress bar 
	$a++ 
	$status = "{0:N0}" -f ($a / $tot * 100) 
	Write-Progress -Activity "Exporting Costs" -status "Processing row $a of $tot : $status% Completed" -PercentComplete ($a / $tot * 100) 

	#// Fix data types
	$csvAll[$i].Date = [datetime]::Parse($csvAll[$i].Date).ToString("d")
	$csvAll[$i].Cost = [float]$csvAll[$i].Cost
	$csvAll[$i].ResourceRate = [float]$csvAll[$i].ResourceRate
	$csvAll[$i].ConsumedQuantity = [float]$csvAll[$i].ConsumedQuantity
}

#// Sort array by date
$csvAll = $csvAll | Sort Date

#// save the data to an Excel file
$csvAll | Export-Csv -Path $CsvFile -NoTypeInformation

#// Release PowerShell memory
[System.GC]::Collect()

#// End of Script


