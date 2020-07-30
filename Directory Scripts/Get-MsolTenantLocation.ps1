#This script is so simple I've deemed comments unnecessary.

$domain = Read-Host "Enter Domain Name"
Write-Host ""

$query = Invoke-RestMethod "https://login.microsoftonline.com/$domain/.well-known/openid-configuration"

$guid = ($query.issuer).Replace("https://sts.windows.net/","").Replace("/","")

Write-Host "Tenant GUID:             $guid"
Write-Host "Tenant Instance Name:    $($query.cloud_instance_name)"
Write-Host "Tenant Region Scope:     $($query.tenant_region_scope)"
Write-Host "Tenant Region Sub-Scope: $($query.tenant_region_sub_scope)"
