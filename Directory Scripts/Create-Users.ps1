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

$users = Get-Content $CsvResolvedPath | ConvertFrom-Csv

#Set absolute variables here, probably change these.
$OrgUnit = Read-Host "Enter OU DN Here:"


foreach($user in $users)
    {
    
    try
        {
        New-ADUser `
        -UserPrincipalName $user.email `
        -EmailAddress $user.email `
        -SamAccountName ($user.email).Split('@')[0] `
        -Path $OrgUnit `
        `
        -Name $user.displayname `
        -DisplayName $user.displayname `
        -GivenName $user.firstname `
        -Surname $user.lastname `
        `
        -Company $Company `
        -Department $user.department `
        -City $user.city `
        -State $user.state `
        -Country $Country `
        -Title $user.title `
        -Description $user.title `
        `
        -MobilePhone $user.mobilephone `
        -AccountPassword ( $user.password | ConvertTo-SecureString -AsPlainText -Force) `
        -ChangePasswordAtLogon $false `
        -CannotChangePassword $false `
        -Enabled $true `
        -Verbose
        }
     
    #If user does not have sufficient rights, terminate script and warn.
    catch [System.UnauthorizedAccessException]
        {
        Write-Warning "The operation failed due to insufficient access rights. Are you running this as Administrator?"
        Return
        }
    
    #If there is a pre-existing user with the conflicy, warn user, but continue running.
    catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException],[Microsoft.ActiveDirectory.Management.ADException]
        {
        Write-Warning "User $($user.displayname) already exists. Skipping user."
        }
    
    }
