ForEach ($user in $list)
    {
    $userUPN = $user.userprincipalname
    $licensePlanList = Get-AzureADSubscribedSku
    $userList = Get-AzureADUser -ObjectID $userUPN | Select -ExpandProperty AssignedLicenses | Select SkuID
    if($userList.Count -ne 0)
        {
        if($userList -is [array])
            {
            for ($i=0; $i -lt $userList.Count; $i++)
                {
                $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
                $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
                $license.SkuId = $userList[$i].SkuId
                $licenses.AddLicenses = $license
                Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
                $Licenses.AddLicenses = @()
                $Licenses.RemoveLicenses =  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $userList[$i].SkuId -EQ).SkuID
                Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
                }
            } 
        else 
            {
            $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
            $license.SkuId = $userList.SkuId
            $licenses.AddLicenses = $license
            Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
            $Licenses.AddLicenses = @()
            $Licenses.RemoveLicenses =  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $userList.SkuId -EQ).SkuID
            Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
            }
        }
    }
