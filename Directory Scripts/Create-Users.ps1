<# 
This script expects a csv file as input with the following fields:

firstname,lastname,displayname,email,password,title,city,state,department,mobilephone

The fields should be named or this will not work properly as is the case for every PS array non-reliant on positioning.

for example:

"Tony","Stark","Tony Stark","tstark@contoso.com","P@$$W0rd","Iron Man","Valencia","CA","Avengers","5555555555"
 
 It is not recommended to hard-set a password, instead a randomly generated password should be created for each user and 
 either emailed directly to them or otherwise communicated in a secure manner. Should you wish to ignore this advice,
 simply replace line 55 below with "-AccountPassword ( "YourPasswordHere" | ConvertTo-SecureString -AsPlainText -Force) `"
 Remember to include the backtick, as it tells Powershell to keeping reading the next line as part of the same command.

#>

#Sets Path to CSV
$CsvPath = Read-Host "Enter Path to CSV"
$CsvResolvedPath = Resolve-Path $CsvPath

$UsersPsList = Get-Content $CsvResolvedPath | ConvertFrom-Csv

#Prompts user for OU.
$Ou = Read-Host "Enter OU DN Here:"

#Attempts to Create User account.
foreach($user in $users)
    {
    
    try
        {
        Write-Host "Creating User $($user.DisplayName)"
    
        New-ADUser `
        -Name $user.DisplayName `
        -DisplayName $user.DisplayName `
        -GivenName $user.GivenName `
        -Surname $user.Surname `
        -SamAccountName $user.SamAccountName `
        -UserPrincipalName $user.UserPrincipalName `
        -Path $Ou `
        -AccountPassword ($user.Password | ConvertTo-SecureString -AsPlainText -Force) `
        -ChangePasswordAtLogon $True `
        -Enabled $true `
        -StreetAddress $user.Address `
        -City $user.City `
        -State $user.State `
        -PostalCode $user.PostalCode `
        -Country $user.Country `
        -Title $user.Title `
        -Department $user.Department `
        -Division $user.Division `
        -Office $user.Office `
        -Company $user.Company `
        -Description $user.Title `
        -EmailAddress $user.UserPrincipalName `
        -MobilePhone $User.Mobile `
        -OfficePhone $User.Phone `
        -Fax $user.Fax `
        }
     
    #If user does not have sufficient rights, terminate script and warn.
    catch [System.UnauthorizedAccessException]
        {
        Write-Warning "The operation to create user $($user.UserPrincipalName) failed due to insufficient access rights. Terminating script."
        Exit
        }
    
    #If there is a pre-existing user with the conflicy, warn user, but continue running.
    catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException],[Microsoft.ActiveDirectory.Management.ADException]
        {
        Write-Warning "The operation to create user $($user.UserPrincipalName) because the user already exists."
        }
    
    }


#Attempts to Set Managers for User Account. This is a seperate step to ensure the manager account is created before attempting to assign them to a user.
foreach($user in $users)
    {
    
    try
        {
        Write-Host "Setting Manager for user $($user.DisplayName) to $($user.ManagerAltDisplayName)"
        Set-ADUser -Identity $user.SamAccountName -Manager $user.ManagerSamAccountName
        }
     
    #If user does not have sufficient rights, terminate script and warn.
    catch [System.UnauthorizedAccessException]
        {
        Write-Warning "The operation to assign set manager for user $($user.UserPrincipalName) as $($user.ManagerAltDisplayName) failed due to insufficient access rights. Terminating script."
        Exit
        }
    
    }
