# Obtains tenant name using dsregcmd, used because I can't figure out how to pull these through the registry where this is easier.
$TenantName = dsregcmd /status | Select-String -Pattern "WorkplaceTenantName :"
$TenantNameValue = $TenantName -replace "WorkplaceTenantName :","" -replace "  ",""

# Obatains Azure AD join information stored in registry.
$ConfigName = (Get-ChildItem "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/JoinInfo").Name
$RegKeyPath = $ConfigName -replace "HKEY_LOCAL_MACHINE","HKLM:"
$RegKey = Get-ItemProperty $RegKeyPath

# Looks up location of tenant with previously retreived GUID from registry
$domain = $RegKey.TenantId
$query = Invoke-RestMethod "https://login.microsoftonline.com/$domain/.well-known/openid-configuration"

# Dervive Likely Tenant cloud variant based on known baselines.
$TenantLookup = `
'SubScope,Value
GCC,GCC
DODCON,GCC HIGH
DOD,DOD
,NA' | ConvertFrom-Csv
$Variant = $TenantLookup | Where-Object SubScope -eq ($query.tenant_region_sub_scope) | Select-Object -ExpandProperty Value

Write-Host "Azure AD Tenant Name:      $TenantNameValue"
Write-Host "Azure AD Tenant GUID:      $domain"
Write-Host "Azure AD Tenant Instance:  $($query.cloud_instance_name)"
Write-Host "Azure AD Tenant Region:    $($query.tenant_region_scope)"
Write-Host "Azure AD Tenant Sub-Scope: $($query.tenant_region_sub_scope)"
Write-Host "Azure AD Tenant Variant:   $Variant"
Write-Host "Azure AD Tenant Enroller:  $($RegKey.UserEmail)"
