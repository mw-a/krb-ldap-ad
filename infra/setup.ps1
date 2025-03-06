$install = "c:\install"
New-Item -Path $install -ItemType "directory"

$ptmsi = "putty-64bit-0.83-installer.msi"
$pturl = "https://the.earth.li/~sgtatham/putty/latest/w64/{0}" -f $ptmsi
$putty = "{0}\{1}" -f ($install, $ptmsi)
Start-BitsTransfer -Source $pturl -Destination $putty
Start-Process -Wait -FilePath msiexec -ArgumentList @("/passive", "/i", $putty)

New-Item -Path "HKCU:\Software\SimonTatham"
New-Item -Path "HKCU:\Software\SimonTatham\PuTTY"
New-Item -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions"
New-Item -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\kdc01"
New-ItemProperty -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\kdc01" -Name HostName -PropertyType String -Value kdc01.example.com
New-Item -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\lx01"
New-ItemProperty -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\lx01" -Name HostName -PropertyType String -Value lx01.example.com
New-Item -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\lx02"
New-ItemProperty -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\lx02" -Name HostName -PropertyType String -Value lx02.ads.example.com
#New-Item -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\adskdc01"
#New-ItemProperty -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\adskdc01" -Name HostName -PropertyType String -Value adskdc01.ads.example.com
#New-Item -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\win01"
#New-ItemProperty -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\win01" -Name HostName -PropertyType String -Value win01.ads.example.com
#New-Item -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\adskdc02"
#New-ItemProperty -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\adskdc02" -Name HostName -PropertyType String -Value adskdc02.subdom.ads.example.com
New-Item -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\lx03"
New-ItemProperty -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions\lx03" -Name HostName -PropertyType String -Value lx03.subdom.ads.example.com

$wzfile = "WinSCP-6.3.7-Setup.exe"
$wzurl = "https://altushost-swe.dl.sourceforge.net/project/winscp/WinSCP/6.3.7/{0}" -f $wzfile
$winzip = "{0}\{1}" -f ($install, $wzfile)
Start-BitsTransfer -Source $wzurl -Destination $winzip
Start-Process -Wait -FilePath $winzip -ArgumentList @("/silent", "/allusers")

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

& 'C:\Program Files\Git\bin\git' clone https://github.com/mw-a/krb-ldap-ad ("{0}\desktop\krb-ldap-ad" -f $env:USERPROFILE)

$ffurl = "https://ftp.mozilla.org/pub/firefox/releases/136.0/win64/en-US/Firefox%20Setup%20136.0.exe"
$ff = "{0}\Firefox-Setup-136.0.exe" -f $install

Start-BitsTransfer -Source $ffurl -Destination $ff
Start-Process -Wait -FilePath $ff -ArgumentList @("/S")
