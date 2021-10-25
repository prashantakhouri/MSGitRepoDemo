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

$destTemporaryContainerName = $(((Get-Date -Format o) -Replace '[^a-zA-Z0-9]','').ToLower())

cd 'C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy'

$sourceStorageAccount = New-AzureStorageContext -StorageAccountName $sourceStorageAccountName -StorageAccountKey $sourceStorageAccountKey
$destStorageAccount = New-AzureStorageContext -StorageAccountName $destStorageAccountName -StorageAccountKey $destStorageAccountKey

$tables = Get-AzureStorageTable -Context $sourceStorageAccount

foreach($table in $tables) {
 Write-Host "Copying source table $($table.Name) from $($sourceStorageAccountName) to temporary storage container $($destTemporaryContainerName) on $($destStorageAccountName)"
 .\AzCopy.exe /Source:https://$sourceStorageAccountName.table.core.windows.net/$($table.Name)/ /Dest:https://$destStorageAccountName.blob.core.windows.net/$destTemporaryContainerName/ /SourceKey:$sourceStorageAccountKey /Destkey:$destStorageAccountKey /Manifest:"$($table.Name).manifest"
 Write-Host "Finished copying source table $($table.Name) from $($sourceStorageAccountName) to temporary storage container $($destTemporaryContainerName) on $($destStorageAccountName)"
 
 Write-Host "Importing data into destination table $($table.Name) from temporary storage container $($destTemporaryContainerName) on $($destStorageAccountName)"
 .\AzCopy.exe /Source:https://$destStorageAccountName.blob.core.windows.net/$destTemporaryContainerName/ /Dest:https://$destStorageAccountName.table.core.windows.net/$($table.Name)/ /SourceKey:$destStorageAccountKey /DestKey:$destStorageAccountKey /Manifest:"$($table.Name).manifest" /EntityOperation:"InsertOrReplace"
 Write-Host "Finished importing data into destination table $($table.Name) from temporary storage container $($destTemporaryContainerName) on $($destStorageAccountName)"
}

Write-Host "Deleting temporary storage container $($destTemporaryContainerName) on $($destStorageAccountName)"
Remove-AzureStorageContainer -Context $destStorageAccount -Name $destTemporaryContainerName -Force
Write-Host "Finished deleting temporary storage container $($destTemporaryContainerName) on $($destStorageAccountName)"
