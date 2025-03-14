Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools

Install-ADDSDomain -DomainType "child" -NewDomainName "subdom" -NewDomainNetBIOSName "SUBDOM" -ParentDomainName "ads.example.com" -Credential (Get-Credential "administrator@ads.example.com") -DomainMode 10 -InstallDns:$False
