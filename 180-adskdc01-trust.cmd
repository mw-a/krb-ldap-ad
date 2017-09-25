netdom.exe trust ADS.EXAMPLE.COM /Domain EXAMPLE.COM /add /realm /twoway /passwordt P@ssw0rd
netdom.exe trust ADS.EXAMPLE.COM /Domain EXAMPLE.COM /transitive:yes
netdom.exe trust ADS.EXAMPLE.COM /Domain EXAMPLE.COM /foresttransitive:yes
netdom.exe trust ADS.EXAMPLE.COM /Domain EXAMPLE.COM /addtln EXAMPLE.COM
ksetup.exe /SetEncTypeAttr EXAMPLE.COM AES256-CTS-HMAC-SHA1-96

