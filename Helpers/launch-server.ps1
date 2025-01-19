param (
    [string]$buildType = "Green",
    [string]$projectFolderName = "FPSTemplate",
    [string]$projectExecutableName = "FPSTemplateServer.exe",
    [string]$fleetId = "fleet-7bce0d08-417b-46de-9064-617a735621bb",
    [string]$fleetArn = "arn:aws:gamelift:us-east-2:767397889935:fleet/fleet-7bce0d08-417b-46de-9064-617a735621bb",
    [string]$computeName = "home-desktop-compute",
    [string]$profileName = "pgadmin",
    [string]$region = "us-east-2",
    [string]$port = "7777",
    [string]$ssoRegion = "us-east-1",
    [string]$startUrl = "https://d-9067c10aca.awsapps.com/start",
    [string]$websocketUrl = "wss://us-east-2.api.amazongamelift.com"

)

Import-Module AWSPowerShell

# Check if the user is already logged in
$loggedIn = Get-STSCallerIdentity -ProfileName $profileName -Region us-east-2 -ErrorAction SilentlyContinue

if (-not $loggedIn) {
    Initialize-AWSSSOConfiguration -Region $ssoRegion -StartUrl $startUrl -SSORegion $ssoRegion -ProfileName $profileName -RegistrationScopes sso:account:access -SessionName $profileName

    # Set the AWS credentials profile (probably don't need both...)
    Get-S3Bucket -ProfileName "$profileName"
    Set-AWSCredential -ProfileName "$profileName"
}
Set-DefaultAWSRegion -Region $region

# Get all IPv4 addresses
Write-Output "Getting all IPv4 addresses..."
$ipv4Addresses = Get-NetIPAddress -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress


# Get the AuthToken
$authTokenResponse = Get-GMLComputeAuthToken -FleetId "$fleetArn" -ComputeName "$computeName" -ProfileName "$profileName"
$authToken = $authTokenResponse.AuthToken

# Check if the compute resource IP address is in the list of IPv4 addresses
$computeIpAddress = (Get-GMLCompute -FleetId "$fleetArn" -ComputeName "$computeName" -ProfileName "$profileName").IPAddress

if ($ipv4Addresses -notcontains $computeIpAddress) {
    Write-Host "Warning: The compute resource IP address ($computeIpAddress) is not in the list of IPv4 addresses of this machine." -ForegroundColor Red
    Write-Host "Delete and recreate the compute resource with your new IP." -ForegroundColor Red
    # Output the list of addresses to the console at the end of the script
    Write-Output "List of IPv4 addresses:"
    $ipv4Addresses | ForEach-Object { Write-Output $_ }
}else {
    Write-Host "The compute resource IP address ($computeIpAddress) is in the list of IPv4 addresses of this machine." -ForegroundColor Green
}

Start-Process -FilePath "..\Build\$buildType\WindowsServer\$projectFolderName\Binaries\Win64\$projectExecutableName" -ArgumentList "-log", "-authtoken=$authToken", "-hostid=$computeName", "-fleetid=$fleetId", "-websocketurl=$websocketUrl", "-port=$port"




