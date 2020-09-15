$UserList = Get-Content .\REMOVED.csv | ConvertFrom-Csv

# Define clear text string for username and password
[string]$userName = 'REMOVED'
[string]$userPassword = 'REMOVED'

# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)


ForEach ($User in $UserList)
{

#Sends email to user with listed new credentials    
$MessageBody = ("
Greetings $($User.DisplayName),
    
Please keep this email as it is important. It contains the information you need to access REMOVED " + `
"that all team members will be using for services such as REMOVED. The below credentials will" + `
" be used for all access for these new services. REMOVED" + `
" message only contains your username and password. See below:
    
Username (UPN / Email format):
$($User.UserPrincipalName)

Username (SAM / Down-Level format):
$($User.sAMAccountName)

Password (must be changed):
$($User.Password)

It is recommended that you immediately change your password by visiting REMOVED

Regards,

REMOVED")

Send-MailMessage `
    -To $User.UserPrincipalName `
    -Body $MessageBody `
    -From $userName `
    -SmtpServer "smtp.office365.com" `
    -Subject "REMOVED" `
    -Credential $credObject `
    -UseSsl
Write-Host -ForegroundColor Green -BackgroundColor Black "Sent email to $($User.DisplayName) at $($User.UserPrincipalName)"

}
