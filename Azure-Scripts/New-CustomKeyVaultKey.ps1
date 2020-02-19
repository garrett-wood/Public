<#This script is used to generate an an Azure KeyVault Key using custom parameters.
At present, this is the only known way to generate a key with basic contsraints
modified to specify the entity as a CA that does not involve the compiled code.
#>

# Variables to obtain token
$TenantId = Read-Host "Enter Tenant ID as Guid" 
$ClientId = Read-Host "Enter Client ID of Authorized Application"
$ClientSecret = Read-Host "Enter Client Secret"
$RequestAccessTokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"
$body = "grant_type=client_credentials&client_id=$ClientId&client_secret=$ClientSecret&resource=$Resource"

#Obtain Token
$Token = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $body

#Variables for Key Vault Access and Certificate Creation
$KeyVaultUrl = Read-Host "Enter FQDN"
$Resource = "https://vault.azure.net"
$CertificateName = Read-Host "Enter Requested Certificate Name"
$PathToJsonPolicy = Read-Host "Enter the relative or full path to your Policy File"
$ApiUri = "$KeyVaultUrl/certificates/$CertificateName/create?api-version=7.0"
$requestBodyAsJson = Get-Content (Resolve-Path $PathToJsonPolicy | Select-Item -Expand Path)

# Build Headers from Token 
$Headers = @{}
$Headers.Add("Authorization","$($Token.token_type) "+ " " + "$($Token.access_token)")
 
# Submit Certificate Creation
Invoke-RestMethod -Uri $ApiUri -Method POST -Headers $headers -Body $requestBodyAsJson -ContentType 'application/json'
