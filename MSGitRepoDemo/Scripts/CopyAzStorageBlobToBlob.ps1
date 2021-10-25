#parameters
param(
[Parameter(Mandatory=$true)]
[String]$sourceStorageAccountName,
[Parameter(Mandatory=$true)]
[String]$sourceStorageAccountKey,
[Parameter(Mandatory=$true)]
[String]$destStorageAccountName,
[String]$destStorageAccountKey
)

# $sourceStorageAccountName = "SOURCE_STORAGE_ACCOUNT_NAME"
# $sourceStorageAccountKey = "SOURCE_STORAGE_ACCOUNT_ACCESS_KEY"
# $destStorageAccountName = "DESTINATION_STORAGE_ACCOUNT_NAME"
# $destStorageAccountKey = "DESTINATION_STORAGE_ACCOUNT_ACCESS_KEY"

cd 'C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy'

$sourceStorageAccount = New-AzureStorageContext -StorageAccountName $sourceStorageAccountName -StorageAccountKey $sourceStorageAccountKey
$destStorageAccount = New-AzureStorageContext -StorageAccountName $destStorageAccountName -StorageAccountKey $destStorageAccountKey

$containers = Get-AzureStorageContainer -Context $sourceStorageAccount
foreach($container in $containers) {
 Write-Host "Copying container $($conatiner.Name) from $($sourceStorageAccountName) to $($destStorageAccountName)"
 .\AzCopy.exe /Source:https://$sourceStorageAccountName.blob.core.windows.net/$($container.Name) /SourceKey:$sourceStorageAccountKey /Dest:https://$destStorageAccountName.blob.core.windows.net/$($container.Name) /DestKey:$destStorageAccountKey /S
}