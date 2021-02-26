function New-MsGraphAccessToken 
{
Param 
    (
    # Should probably validate these in some way.
    $TenantId,
    $ClientId,
    $ClientSecret
)
    # Pulls proper Graph and Token endpoitns from Domain using Well Known OpenId Configuration Endpoint
    $TenantWellKnown = Invoke-RestMethod -uri "https://login.microsoftonline.com/$TenantId/v2.0/.well-known/openid-configuration"
    $GraphEndpoint = $TenantWellKnown.msgraph_host
    $TokenEndpoint = $TenantWellKnown.token_endpoint

    # Sends request to acquire bearer token
    $ApiConnection = Invoke-RestMethod `
    -Method Post `
    -Uri $TokenEndpoint `
    -ContentType 'application/x-www-form-urlencoded' `
    -Body @{
        client_id = "$ClientId"
        scope =  "https://$GraphEndpoint/.default"
        client_secret = "$ClientSecret"
        grant_type = "client_credentials"
    }
    # Returns PSObject which contains the token as a secure string, graph and point and Tenant Id. These are returned in case
    # further references are needed in dependent functions.
    $BearerToken = ($ApiConnection.access_token | ConvertTo-SecureString -AsPlainText -Force)
    $Output = New-Object -TypeName PSObject
    $Output | Add-Member -MemberType NoteProperty -Name BearerToken -Value $BearerToken
    $Output | Add-Member -MemberType NoteProperty -Name GraphHost -Value $GraphEndpoint
    $Output | Add-Member -MemberType NoteProperty -Name TenantScope -Value $TenantId
    Return $Output
}
