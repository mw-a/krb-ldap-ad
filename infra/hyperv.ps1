Install-WindowsFeature -Name DNS
Install-WindowsFeature -Name RSAT-DNS-Server

$DnsServerSettings = Get-DnsServerSetting -ALL
$DnsServerSettings.ListeningIpAddress = @("192.168.200.1")
Set-DNSServerSetting $DnsServerSettings

Set-DnsClientServerAddress -InterfaceAlias "vEthernet (LabServicesSwitch)" -ServerAddresses 192.168.200.1
Set-DnsClientGlobalSetting -SuffixSearchList @("example.com", "ads.example.com", "subdom.ads.example.com")

$domain = "example.com"
Remove-DnsServerZone -Name $domain -Force
Add-DnsServerPrimaryZone -Name $domain -DynamicUpdate NonsecureAndSecure -ZoneFile ("{0}.dns" -f $domain)
$soa = Get-DNSServerResourceRecord -RRType SOA -ZoneName $domain
$newsoa = $soa.Clone()
$newsoa.RecordData.PrimaryServer = "hyperv.example.com."
Set-DnsServerResourceRecord -NewInputObject $newsoa -OldInputObject $soa -ZoneName $domain

$revdomain = "200.168.192.in-addr.arpa"
Remove-DnsServerZone -Name $revdomain -Force
Add-DnsServerPrimaryZone -NetworkID 192.168.200.0/24 -ZoneFile ("{0}.dns" -f $revdomain)
$soa = Get-DNSServerResourceRecord -RRType SOA -ZoneName $revdomain
$newsoa = $soa.Clone()
$newsoa.RecordData.PrimaryServer = "hyperv.example.com."
Set-DnsServerResourceRecord -NewInputObject $newsoa -OldInputObject $soa -ZoneName $revdomain

Add-DnsServerResourceRecordA -Name "hyperv" -ZoneName $domain -IPv4Address "192.168.200.1" -TimeToLive 01:00:00 -CreatePtr
Add-DnsServerResourceRecordA -Name "kdc01" -ZoneName $domain -IPv4Address "192.168.200.102" -TimeToLive 01:00:00 -CreatePtr
Add-DnsServerResourceRecordA -Name "lx01" -ZoneName $domain -IPv4Address "192.168.200.103" -TimeToLive 01:00:00 -CreatePtr
Add-DnsServerResourceRecordA -Name "lx02.ads" -ZoneName $domain -IPv4Address "192.168.200.104" -TimeToLive 01:00:00 -CreatePtr
Add-DnsServerResourceRecordA -Name "adskdc01.ads" -ZoneName $domain -IPv4Address "192.168.200.105" -TimeToLive 01:00:00 -CreatePtr
Add-DnsServerResourceRecordA -Name "win01.ads" -ZoneName $domain -IPv4Address "192.168.200.106" -TimeToLive 01:00:00 -CreatePtr
Add-DnsServerResourceRecordA -Name "adskdc02.subdom.ads" -ZoneName $domain -IPv4Address "192.168.200.107" -TimeToLive 01:00:00 -CreatePtr
Add-DnsServerResourceRecordA -Name "lx03.subdom.ads" -ZoneName $domain -IPv4Address "192.168.200.108" -TimeToLive 01:00:00 -CreatePtr

Set-DhcpServerV4Scope -ScopeId 192.168.200.0 -StartRange 192.168.200.100 -EndRange 192.168.200.220
Set-DhcpServerv4Scope -ScopeId 192.168.200.0 -StartRange 192.168.200.200 -EndRange 192.168.200.220
Set-DhcpServerV4OptionValue -ScopeId 192.168.200.0 -DnsServer 192.168.200.1

for ($i = 102; $i -le 108; $i++) {
	Remove-DhcpServerV4Reservation -IPAddress 192.168.200.$i
}

Add-DhcpServerV4Reservation -ScopeId 192.168.200.0 -Type "DHCP" -ClientId "00-15-5d-00-05-01" -IPAddress 192.168.200.102 -Name ("kdc01.{0}" -f $domain)
Add-DhcpServerV4Reservation -ScopeId 192.168.200.0 -Type "DHCP" -ClientId "00-15-5d-00-05-02" -IPAddress 192.168.200.103 -Name ("lx01.{0}" -f $domain)
Add-DhcpServerV4Reservation -ScopeId 192.168.200.0 -Type "DHCP" -ClientId "00-15-5d-00-05-03" -IPAddress 192.168.200.104 -Name ("lx02.{0}" -f $domain)
Add-DhcpServerV4Reservation -ScopeId 192.168.200.0 -Type "DHCP" -ClientId "00-15-5d-00-05-04" -IPAddress 192.168.200.105 -Name ("adskdc01.ads.{0}" -f $domain)
Add-DhcpServerV4Reservation -ScopeId 192.168.200.0 -Type "DHCP" -ClientId "00-15-5d-00-05-05" -IPAddress 192.168.200.106 -Name ("win01.ads.{0}" -f $domain)
Add-DhcpServerV4Reservation -ScopeId 192.168.200.0 -Type "DHCP" -ClientId "00-15-5d-00-05-06" -IPAddress 192.168.200.107 -Name ("adskdc02.subdom.ads.{0}" -f $domain)
Add-DhcpServerV4Reservation -ScopeId 192.168.200.0 -Type "DHCP" -ClientId "00-15-5d-00-05-07" -IPAddress 192.168.200.108 -Name ("lx03.subdom.ads.{0}" -f $domain)

Remove-VM -Name DC01 -Force
Remove-VM -Name Linux01 -Force
Remove-VM -Name W11 -Force

Remove-Item -Path ("{0}\Microsoft\Windows\Virtual Hard Disks\DC01.vhdx" -f $env:PROGRAMDATA)
Remove-Item -Path ("{0}\Microsoft\Windows\Virtual Hard Disks\Linux01.vhdx" -f $env:PROGRAMDATA)
Remove-Item -Path ("{0}\Microsoft\Windows\Virtual Hard Disks\W11.vhdx" -f $env:PROGRAMDATA)

Remove-Item -Path "c:\install\ubuntu-22.10-live-server-amd64.iso"

$vms = 'kdc01', 'lx01', 'lx02', 'adskdc01', 'win01', 'adskdc02', 'lx03'
foreach ($vm in $vms) {
	Stop-VM -Name $vm -Force
	Remove-VM -Name $vm -Force
	Remove-Item -Path ("{0}\Microsoft\Windows\Virtual Hard Disks\{1}.vhdx" -f $env:PROGRAMDATA, $vm)
}

$install = "c:\install"
#$isoname = "debian-11.6.0-amd64-netinst.iso"
$isoname = "efiboot.iso"
$netinst = "{0}\{1}" -f ($install, $isoname)
#$niurl = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/{0}" -f $isoname
#Start-BitsTransfer -Source $niurl -Destination $netinst

$adskdcinst = "{0}\26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso" -f $install
$adskdc01au = "{0}\adskdc01-autounattend.iso" -f $install
$wininst = "{0}\Win11_24H2_English_x64.iso" -f $install
$win01au = "{0}\win01-autounattend.iso" -f $install
$adskdc02au = "{0}\adskdc02-autounattend.iso" -f $install

$kdc01 = New-VM  -Generation 2 -MemoryStartupBytes 2GB -Name kdc01 -NewVHDPath "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\kdc01.vhdx" -NewVHDSizeBytes 20GB -SwitchName "LabServicesSwitch"
$dvd = Add-VMDvdDrive -VMName $kdc01.VMName -Path $netinst -Passthru
Set-VMFirmware -VM $kdc01 -FirstBootDevice $dvd -SecureBootTemplate MicrosoftUEFICertificateAuthority
Set-VMNetworkAdapter -VM $kdc01 -StaticMacAddress "00:15:5d:00:05:01"

$lx01 = New-VM  -Generation 2 -MemoryStartupBytes 2GB -Name lx01 -NewVHDPath "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\lx01.vhdx" -NewVHDSizeBytes 20GB -SwitchName "LabServicesSwitch"
$dvd = Add-VMDvdDrive -VM $lx01 -Path $netinst -Passthru
Set-VMFirmware -VM $lx01 -FirstBootDevice $dvd -SecureBootTemplate MicrosoftUEFICertificateAuthority
Set-VMNetworkAdapter -VM $lx01 -StaticMacAddress "00:15:5d:00:05:02"

$lx02 = New-VM  -Generation 2 -MemoryStartupBytes 2GB -Name lx02 -NewVHDPath "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\lx02.vhdx" -NewVHDSizeBytes 20GB -SwitchName "LabServicesSwitch"
$dvd = Add-VMDvdDrive -VM $lx02 -Path $netinst -Passthru
Set-VMFirmware -VM $lx02 -FirstBootDevice $dvd -SecureBootTemplate MicrosoftUEFICertificateAuthority
Set-VMNetworkAdapter -VM $lx02 -StaticMacAddress "00:15:5d:00:05:03"

$adskdc01 = New-VM  -Generation 2 -MemoryStartupBytes 2GB -Name adskdc01 -NewVHDPath "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\adskdc01.vhdx" -NewVHDSizeBytes 30GB -SwitchName "LabServicesSwitch"
$dvd = Add-VMDvdDrive -VM $adskdc01 -Path $adskdcinst -Passthru
Add-VMDvdDrive -VM $adskdc01 -Path $adskdc01au -Passthru
Set-VMFirmware -VM $adskdc01 -FirstBootDevice $dvd
Set-VMNetworkAdapter -VM $adskdc01 -StaticMacAddress "00:15:5d:00:05:04"

$win01 = New-VM  -Generation 2 -MemoryStartupBytes 4GB -Name win01 -NewVHDPath "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\win01.vhdx" -NewVHDSizeBytes 30GB -SwitchName "LabServicesSwitch"
Set-VMProcessor -VM $win01 -Count 2
$win01hg = Get-HgsGuardian -Name 'UntrustedGuardian'
$win01kp = New-HgsKeyProtector -Owner $win01hg -AllowUntrustedRoot
Set-VMKeyProtector -VM $win01 -KeyProtector $win01kp.RawData
Enable-VMTPM -VM $win01
$dvd = Add-VMDvdDrive -VM $win01 -Path $wininst -Passthru
Add-VMDvdDrive -VM $win01 -Path $win01au -Passthru
Set-VMFirmware -VM $win01 -FirstBootDevice $dvd
Set-VMNetworkAdapter -VM $win01 -StaticMacAddress "00:15:5d:00:05:05"

$adskdc02 = New-VM  -Generation 2 -MemoryStartupBytes 2GB -Name adskdc02 -NewVHDPath "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\adskdc02.vhdx" -NewVHDSizeBytes 30GB -SwitchName "LabServicesSwitch"
$dvd = Add-VMDvdDrive -VM $adskdc02 -Path $adskdcinst -Passthru
Add-VMDvdDrive -VM $adskdc02 -Path $adskdc02au -Passthru
Set-VMFirmware -VM $adskdc02 -FirstBootDevice $dvd
Set-VMNetworkAdapter -VM $adskdc02 -StaticMacAddress "00:15:5d:00:05:06"

$lx03 = New-VM  -Generation 2 -MemoryStartupBytes 2GB -Name lx03 -NewVHDPath "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\lx03.vhdx" -NewVHDSizeBytes 20GB -SwitchName "LabServicesSwitch"
$dvd = Add-VMDvdDrive -VM $lx03 -Path $netinst -Passthru
Set-VMFirmware -VM $lx03 -FirstBootDevice $dvd -SecureBootTemplate MicrosoftUEFICertificateAuthority
Set-VMNetworkAdapter -VM $lx03 -StaticMacAddress "00:15:5d:00:05:07"

$ptmsi = "putty-64bit-0.83-installer.msi"
$pturl = "https://the.earth.li/~sgtatham/putty/latest/w64/{0}" -f $ptmsi
$putty = "{0}\{1}" -f ($install, $ptmsi)
Start-BitsTransfer -Source $pturl -Destination $putty
Start-Process -Wait -FilePath msiexec -ArgumentList @("/passive", "/i", $putty)
Remove-Item -Path $putty

Remove-Item -Path HKCU:\Software\SimonTatham -Recurse
New-Item -Path HKCU:\Software\SimonTatham
New-Item -Path HKCU:\Software\SimonTatham\PuTTY
New-Item -Path HKCU:\Software\SimonTatham\PuTTY\Sessions
New-Item -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\kdc01
New-ItemProperty -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\kdc01 -Name HostName -PropertyType String -Value kdc01.example.com
New-Item -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\lx01
New-ItemProperty -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\lx01 -Name HostName -PropertyType String -Value lx01.example.com
New-Item -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\lx02
New-ItemProperty -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\lx02 -Name HostName -PropertyType String -Value lx02.ads.example.com
#New-Item -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\adskdc01
#New-ItemProperty -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\adskdc01 -Name HostName -PropertyType String -Value adskdc01.ads.example.com
#New-Item -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\win01
#New-ItemProperty -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\win01 -Name HostName -PropertyType String -Value win01.ads.example.com
#New-Item -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\adskdc02
#New-ItemProperty -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\adskdc02 -Name HostName -PropertyType String -Value adskdc02.subdom.ads.example.com
New-Item -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\lx03
New-ItemProperty -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\lx03 -Name HostName -PropertyType String -Value lx03.subdom.ads.example.com

$wscpfile = "WinSCP-6.3.7-Setup.exe"
$wscpurl = "https://altushost-swe.dl.sourceforge.net/project/winscp/WinSCP/6.3.7/{0}" -f $wscpfile
$winscp = "{0}\{1}" -f ($install, $wscpfile)
Start-BitsTransfer -Source $wscpurl -Destination $winscp
Start-Process -Wait -FilePath $winscp -ArgumentList @("/silent", "/allusers")
Remove-Item -Path $winscp

Remove-Item -Path "HKCU:\Software\Martin Prikryl" -Recurse
New-Item -Path "HKCU:\Software\Martin Prikryl"
New-Item -Path "HKCU:\Software\Martin Prikryl\WinSCP 2"
New-Item -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions"
New-Item -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\kdc01"
New-ItemProperty -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\kdc01" -Name HostName -PropertyType String -Value kdc01.example.com
New-Item -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\lx01"
New-ItemProperty -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\lx01" -Name HostName -PropertyType String -Value lx01.example.com
New-Item -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\lx02"
New-ItemProperty -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\lx02" -Name HostName -PropertyType String -Value lx02.ads.example.com
#New-Item -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\adskdc01"
#New-ItemProperty -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\adskdc01" -Name HostName -PropertyType String -Value adskdc01.ads.example.com
#New-Item -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\win01"
#New-ItemProperty -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\win01" -Name HostName -PropertyType String -Value win01.ads.example.com
#New-Item -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\adskdc02"
#New-ItemProperty -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\adskdc02" -Name HostName -PropertyType String -Value adskdc02.subdom.ads.example.com
New-Item -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\lx03"
New-ItemProperty -Path "HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\lx03" -Name HostName -PropertyType String -Value lx03.subdom.ads.example.com

$gitfile = "Git-2.48.1-64-bit.exe"
$giturl = "https://github.com/git-for-windows/git/releases/download/v2.48.1.windows.1/{0}" -f $gitfile
$git = "{0}\{1}" -f ($install, $gitfile)
Start-BitsTransfer -Source $giturl -Destination $git
Start-Process -Wait -FilePath $git -ArgumentList @("/verysilent")
Remove-Item -Path $git

$git = 'C:\Program Files\Git\bin\git'
$repodir = 'c:\users\workshop\desktop\krb-ldap-ad'
if (Test-Path -Path $repodir) {
	Set-Location -Path $repodir
	& $git pull
} else {
	& $git clone https://github.com/mw-a/krb-ldap-ad $repodir
}

$dir = [Environment]::GetFolderPath("Desktop")
$wscript = New-Object -ComObject ("WScript.Shell")
$shortcut = $wscript.CreateShortcut("$dir\InputLanguage.url")
$shortcut.TargetPath = "ms-settings:regionlanguage"
$shortcut.Save()

$shortcut = $wscript.CreateShortcut("$dir\DefaultInputLanguage.url")
$shortcut.TargetPath = "ms-settings:typing"
$shortcut.Save()

$shortcut = $wscript.CreateShortcut("$dir\PuTTY.lnk")
$shortcut.TargetPath = "C:\Program Files\PuTTY\putty.exe"
$shortcut.IconLocation = "C:\Program Files\PuTTY\putty.exe"
$shortcut.Save()

$LanguageList = Get-WinUserLanguageList
$LanguageList.Clear()
$LanguageList.Add("en-US")
$LanguageList.Add("de-DE")
$LanguageList.Add("en-GB")
Set-WinUserLanguageList $LanguageList -Force
