$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

Set-Location "$PSScriptRoot"
tms build -full


&"$PSScriptRoot\multide\multide.exe" --version
$version = Get-Content "$PSScriptRoot\multide.version.txt"
$targetFolder = "$PSScriptRoot\releases\multide-$($version)"

if (Test-Path $targetFolder) {
    throw "Folder $($targetFolder) already exists. Please increase the version number."
}

mkdir "$targetFolder" -Force

Compress-Archive -Path $PSScriptRoot\multide\multide.exe,$PSScriptRoot\multide\ide-images -DestinationPath "$targetFolder/multide.zip" -Force


Set-Location "$targetFolder"
gh release create "v$($version)" -n "Release of Multide $($version)" "multide.zip"
Write-Host "Release created with version: $($version)"

Set-Location "$PSScriptRoot"