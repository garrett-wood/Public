# This script will rename any users with a UPN matching the default onmicrosoft domain with a UPN using your chosen suffix.

$users = Get-MsolUser -All | Where-Object UserPrincipalName -Like "*onmicrosoft.com" | Where-Object Firstname -ne $null | Select *
$newdomain = Read-Host "Enter new domain name"

ForEach ($user in $users)
    {
    $newupn = $user.UserPrincipalName.Split('@')[0] + $newdomain
    Set-MsolUserPrincipalName -ObjectId $user.ObjectId -NewUserPrincipalName $newupn
    Write-Host "User Named: $($user.UserPrincipalName) name was changed to $($newupn)"
    }
