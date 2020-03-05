
#Create PS Profile
If (Test-Path $profile -eq $false)
    { 
    New-Item -Type File -Force $PROFILE

    #Todo: Set Profile Content
    
    }

#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Install Chocolatey Progr  ams
$ChocolateyPrograms = @("7zip.install","vlc","git.install","putty.install")
choco install $ChocolateyPrograms -y

#Enable Windows Capabilities
#Get-WindowsCapability -Online | Where-Object Name -Like "Rsat.*" | Add-WindowsCapability -Online

#Enable WindowsOptionalFeature
$OptionalFeatures = @("Microsoft-Windows-Subsystem-Linux","Containers-DisposableClientVM","Microsoft-Hyper-V-All")
Enable-WindowsOptionalFeature -Online -FeatureName $OptionalFeatures -NoRestart

#Disable SMBv1
Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Client" -NoRestart
