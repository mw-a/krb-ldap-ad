#!/bin/bash

kadmin -r EXAMPLE.COM -p user/admin@EXAMPLE.COM <<EOF
P@ssw0rd
addprinc -pw P@ssw0rd -clearpolicy krbtgt/ADS.EXAMPLE.COM@EXAMPLE.COM
addprinc -pw P@ssw0rd -clearpolicy krbtgt/EXAMPLE.COM@ADS.EXAMPLE.COM
EOF
