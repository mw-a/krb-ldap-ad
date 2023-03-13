#/bin/bash -e

nmcli c m "Wired connection 1" ipv4.dns-search "example.com ads.example.com subdom.ads.example.com"
