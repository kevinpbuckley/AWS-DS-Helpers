param (
    [string]$buildType = "Green",
    [string]$projectFolderName = "FPSTemplate"
)

# Define source and destination paths
$sourcePaths = @(
    "OpenSSLBinaries\libcrypto-3-x64.dll",
    "OpenSSLBinaries\libssl-3-x64.dll",
    "Install\WindowsServer\install.bat"
)

$destinations = @(
    "..\Build\$buildType\WindowsServer\$projectFolderName\Binaries\Win64",
    "..\Build\$buildType\WindowsServer"
)

# Copy OpenSSL binaries to the specified build directory
foreach ($source in $sourcePaths[0..1]) {
    try {
        Copy-Item -Path $source -Destination $destinations[0] -Force -ErrorAction Stop
    } catch {
        Write-Error "Failed to copy $source to $destinations[0]"
        exit 1
    }
}

# Copy install.bat to the specified build directory
try {
    Copy-Item -Path $sourcePaths[2] -Destination $destinations[1] -Force -ErrorAction Stop
} catch {
    Write-Error "Failed to copy $sourcePaths[2] to $destinations[1]"
    exit 1
}

Write-Output "Files copied successfully to the $buildType build."
