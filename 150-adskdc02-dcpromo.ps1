Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools

Install-ADDSDomain -DomainType "child" -NewDomainName "subdom" -NewDomainNetBIOSName "SUBDOM" -ParentDomainName "ads.example.com" -Credential (Get-Credential "ADS\Administrator") -DomainMode 10 -InstallDns:$False
