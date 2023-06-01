Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools

Install-ADDSForest -DomainName "ads.example.com" -DomainNetBIOSName "ADS" -ForestMode 7 -DomainMode 7 -InstallDns:$False
