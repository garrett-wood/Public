<#
.SYNOPSIS
    This script can be used to sign code by invoking it.
.DESCRIPTION
    It performs a login to Azure AD using MSAL.PS, then uses that token to sign the indicated file(s) using a key store in Azure Key Vault. It is currently setup to be agnostic to cloud location eg. US Gov vs Commercial. Probably works with others too, but I only test my scripts in the US Gov cloud.Requirements:
.DEPENDENCIES
    MSAL.PS PowerShell Module (https://www.powershellgallery.com/packages/MSAL.PS/4.37.0.0)
    AzureSignTool Nuget Package (https://www.nuget.org/packages/AzureSignTool/)
    An Azure AD User Account with Access to an Azure Key Vault
    An Application Registration for MSAL.PS with a set up Redirect Uri
.EXAMPLE
    $files = Get-ChildItem .\ | Where-Object Extension -like *exe
    script.ps1 `
    -keyvaulturi https://mykv.vault.usgovcloudapi.net/ `
    -clientid guidguid-guid-guid-guid-guidguidguid `
    -keyvaultcertificate Test-Signing-Certificate 
    -TimestampUri http://timestamp.yourserver.net/rfc3161
    -Target $files
.EXAMPLE
    script.ps1 `
    -keyvaulturi https://mykv.vault.usgovcloudapi.net/ `
    -clientid guidguid-guid-guid-guid-guidguidguid `
    -keyvaultcertificate Test-Signing-Certificate 
    -TimestampUri http://timestamp.yourserver.net/rfc3161
.EXAMPLE
    script.ps1 `
    -keyvaulturi https://mykv.vault.usgovcloudapi.net/ `
    -clientid guidguid-guid-guid-guid-guidguidguid `
    -keyvaultcertificate Test-Signing-Certificate 
    -TimestampUri http://timestamp.yourserver.net/rfc3161 `
    -TenantId guidguid-guid-guid-guid-guidguidguid 
#>


Param
(

	[Parameter(Mandatory=$true)][String]$KeyVaultUri,
	[Parameter(Mandatory=$true)][String]$KeyVaultCertificate,
	[Parameter(Mandatory=$true)][String]$TimestampUri,
	[Parameter(Mandatory=$true)][String]$ClientId,
	[String]$TenantId,
	[Array]$Target
	
 )

<#
DEPENDENCY CHECKING -
#>

# Checks to make sure MSAL.PS is installed. This script won't work without it. Todo: version checking.

try 
	{ Import-Module MSAL.PS }
catch
	{
	Write-Error "This script requires MSAL.PS to run. MSAL.PS was not found. Run `"Install-Module MSAL.PS`" to use this script"
	Exit 1
	}

# Checks to make sure Azure Sign Tool is installed. This script won't work without it. Todo: Version checking.

try
	{ AzureSignTool.exe -h | Out-Null }
catch
	{ 
	Write-Error "This script cannot call Azure Sign Tool. Please visit https://www.nuget.org/packages/AzureSignTool/ to install."
	Exit 1
	}


<#
AUTHENTICATION
#>

# Validates the Key Vault Uri, stops if invalid, retreives the resource Id for the OAuth token scope if valid.

If (!($KeyVaultUri -match "(https:\/\/)([a-zA-Z0-9\-]{2,24}\.)(vault\.[a-z]+\.[a-z]+)(\/*)"))
	{
	Write-Error "Key Vault Uri is invalid. Please check your Uri"
	Exit 1
	}
Else
	{
	$Scope = $matches[1] + $matches[3] + '/user_impersonation'
	}

# Checks if there's a tenant Id, specified. If not, pulls one from the AAD the machine is joined to as a backup.

If (!$TenantId){$TenantId = (Get-ItemProperty (Get-ChildItem "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/JoinInfo").Name.Replace("HKEY_LOCAL_MACHINE","HKLM:")).TenantId}
$WellKnown = Invoke-RestMethod "https://login.microsoftonline.com/$TenantId/v2.0/.well-known/openid-configuration"


# Spawns a webform to login to in order to obtain an access token.
$msalToken = Get-MsalToken `
	-Interactive `
	-RedirectUri ("https://login." + $WellKnown.cloud_instance_name + "/common/oauth2/nativeclient") `
	-Authority $WellKnown.issuer `
	-ClientId $ClientId `
	-Scopes $Scope

<#
FILE ASSIGNMENT
#>

# If the file to sign isn't specified by the input, spawn a selection box instead. If there is a file or files, use those. Exit if the file can't be accessed.

if (!$Target)
	{
$initialDirectory = [environment]::getfolderpath("Desktop")
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "Executable Files|*.ps1;*.dll;*.msi;*.exe;*.appx;*.appxbundle"
    $OpenFileDialog.ShowDialog() | Out-Null
$Target = $OpenFileDialog.FileName

	if (!(Test-Path $Target))
		{
		Write-Error "Unable to access file."
		Exit 1
		}
	}

<#
SIGNING
#>

# Signs the files. You know how this works.
AzureSignTool.exe sign `
    --azure-key-vault-url $KeyVaultUri `
    --azure-key-vault-accesstoken $msalToken.AccessToken `
    --azure-key-vault-certificate $KeyVaultCertificate `
    --timestamp-rfc3161 $TimestampUri `
    $Target
