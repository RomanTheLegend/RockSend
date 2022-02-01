$TmpDir = '..\tmp'

function PackCodeToZip{
param (
[Parameter()] [String] $Filename
)
Write-Output "Packing $Filename.py to $Filename.zip"
Copy-Item .\$Filename.py $TmpDir\lambda_function.py -Force | Out-Null
Compress-Archive -Force -LiteralPath ..\tmp\lambda_function.py -DestinationPath ..\packages\$Filename.zip | Out-Null
}

New-Item -Path $TmpDir -ItemType Directory | Out-Null

$PythonFiles = @("get_areas", "get_regions", "get_sectors", "get_walls", "get_routes")

foreach ($filename in $PythonFiles) {
PackCodeToZip -Filename $filename
}

Remove-Item $TmpDir -Recurse -Force