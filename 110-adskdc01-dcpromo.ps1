Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools

Install-ADDSForest -DomainName "ads.example.com" -DomainNetBIOSName "ADS" -ForestMode 10 -DomainMode 10 -InstallDns:$False
