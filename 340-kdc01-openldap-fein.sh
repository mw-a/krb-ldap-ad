#!/bin/sh

[ `hostname -s` != 'kdc01' ] && exit 1

systemctl stop slapd.service

slapcat > /root/example.com.ldif.dump
grep groupOfEntries /root/example.com.ldif.dump > /dev/null
if [ $? = 0 ]; then
  rm /root/example.com.ldif.dump
else
  mv /root/example.com.ldif.dump /root/example.com.ldif
fi

cat > /etc/ldap/schema/groupofentries.schema <<EOF
objectclass ( 1.2.826.0.1.3458854.2.1.1.1
      NAME 'groupOfEntries'
      SUP top
      STRUCTURAL
      MUST ( cn )
      MAY ( member $ businessCategory $ seeAlso $ owner $ ou $
            o $ description ) )
EOF

aptitude -y install krb5-kdc-ldap

zcat /usr/share/doc/krb5-kdc-ldap/kerberos.schema.gz > /etc/ldap/schema/kerberos.schema

# make posixGroup AUXILIARY...
cat > /etc/ldap/schema/nis.schema <<"EOF"
# $OpenLDAP$
## This work is part of OpenLDAP Software <http://www.openldap.org/>.
##
## Copyright 1998-2014 The OpenLDAP Foundation.
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted only as authorized by the OpenLDAP
## Public License.
##
## A copy of this license is available in the file LICENSE in the
## top-level directory of the distribution or, alternatively, at
## <http://www.OpenLDAP.org/license.html>.

# Definitions from RFC2307 (Experimental)
#	An Approach for Using LDAP as a Network Information Service

# Depends upon core.schema and cosine.schema

# Note: The definitions in RFC2307 are given in syntaxes closely related
# to those in RFC2252, however, some liberties are taken that are not
# supported by RFC2252.  This file has been written following RFC2252
# strictly.

# OID Base is iso(1) org(3) dod(6) internet(1) directory(1) nisSchema(1).
# i.e. nisSchema in RFC2307 is 1.3.6.1.1.1
#
# Syntaxes are under 1.3.6.1.1.1.0 (two new syntaxes are defined)
#	validaters for these syntaxes are incomplete, they only
#	implement printable string validation (which is good as the
#	common use of these syntaxes violates the specification).
# Attribute types are under 1.3.6.1.1.1.1
# Object classes are under 1.3.6.1.1.1.2

# Attribute Type Definitions

# builtin
#attributetype ( 1.3.6.1.1.1.1.0 NAME 'uidNumber'
#	DESC 'An integer uniquely identifying a user in an administrative domain'
#	EQUALITY integerMatch
#	SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VALUE )

# builtin
#attributetype ( 1.3.6.1.1.1.1.1 NAME 'gidNumber'
#	DESC 'An integer uniquely identifying a group in an administrative domain'
#	EQUALITY integerMatch
#	SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.2 NAME 'gecos'
	DESC 'The GECOS field; the common name'
	EQUALITY caseIgnoreIA5Match
	SUBSTR caseIgnoreIA5SubstringsMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.3 NAME 'homeDirectory'
	DESC 'The absolute path to the home directory'
	EQUALITY caseExactIA5Match
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.4 NAME 'loginShell'
	DESC 'The path to the login shell'
	EQUALITY caseExactIA5Match
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.5 NAME 'shadowLastChange'
	EQUALITY integerMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.6 NAME 'shadowMin'
	EQUALITY integerMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.7 NAME 'shadowMax'
	EQUALITY integerMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.8 NAME 'shadowWarning'
	EQUALITY integerMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.9 NAME 'shadowInactive'
	EQUALITY integerMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.10 NAME 'shadowExpire'
	EQUALITY integerMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.11 NAME 'shadowFlag'
	EQUALITY integerMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.12 NAME 'memberUid'
	EQUALITY caseExactIA5Match
	SUBSTR caseExactIA5SubstringsMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )

attributetype ( 1.3.6.1.1.1.1.13 NAME 'memberNisNetgroup'
	EQUALITY caseExactIA5Match
	SUBSTR caseExactIA5SubstringsMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )

attributetype ( 1.3.6.1.1.1.1.14 NAME 'nisNetgroupTriple'
	DESC 'Netgroup triple'
	SYNTAX 1.3.6.1.1.1.0.0 )

attributetype ( 1.3.6.1.1.1.1.15 NAME 'ipServicePort'
	EQUALITY integerMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.16 NAME 'ipServiceProtocol'
	SUP name )

attributetype ( 1.3.6.1.1.1.1.17 NAME 'ipProtocolNumber'
	EQUALITY integerMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.18 NAME 'oncRpcNumber'
	EQUALITY integerMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.19 NAME 'ipHostNumber'
	DESC 'IP address'
	EQUALITY caseIgnoreIA5Match
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.26{128} )

attributetype ( 1.3.6.1.1.1.1.20 NAME 'ipNetworkNumber'
	DESC 'IP network'
	EQUALITY caseIgnoreIA5Match
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.26{128} SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.21 NAME 'ipNetmaskNumber'
	DESC 'IP netmask'
	EQUALITY caseIgnoreIA5Match
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.26{128} SINGLE-VALUE )

attributetype ( 1.3.6.1.1.1.1.22 NAME 'macAddress'
	DESC 'MAC address'
	EQUALITY caseIgnoreIA5Match
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.26{128} )

attributetype ( 1.3.6.1.1.1.1.23 NAME 'bootParameter'
	DESC 'rpc.bootparamd parameter'
	SYNTAX 1.3.6.1.1.1.0.1 )

attributetype ( 1.3.6.1.1.1.1.24 NAME 'bootFile'
	DESC 'Boot image name'
	EQUALITY caseExactIA5Match
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )

attributetype ( 1.3.6.1.1.1.1.26 NAME 'nisMapName'
	SUP name )

attributetype ( 1.3.6.1.1.1.1.27 NAME 'nisMapEntry'
	EQUALITY caseExactIA5Match
	SUBSTR caseExactIA5SubstringsMatch
	SYNTAX 1.3.6.1.4.1.1466.115.121.1.26{1024} SINGLE-VALUE )

# Object Class Definitions

objectclass ( 1.3.6.1.1.1.2.0 NAME 'posixAccount'
	DESC 'Abstraction of an account with POSIX attributes'
	SUP top AUXILIARY
	MUST ( cn $ uid $ uidNumber $ gidNumber $ homeDirectory )
	MAY ( userPassword $ loginShell $ gecos $ description ) )

objectclass ( 1.3.6.1.1.1.2.1 NAME 'shadowAccount'
	DESC 'Additional attributes for shadow passwords'
	SUP top AUXILIARY
	MUST uid
	MAY ( userPassword $ shadowLastChange $ shadowMin $
	      shadowMax $ shadowWarning $ shadowInactive $
	      shadowExpire $ shadowFlag $ description ) )

objectclass ( 1.3.6.1.1.1.2.2 NAME 'posixGroup'
	DESC 'Abstraction of a group of accounts'
	SUP top AUXILIARY
	MUST ( cn $ gidNumber )
	MAY ( userPassword $ memberUid $ description ) )

objectclass ( 1.3.6.1.1.1.2.3 NAME 'ipService'
	DESC 'Abstraction an Internet Protocol service'
	SUP top STRUCTURAL
	MUST ( cn $ ipServicePort $ ipServiceProtocol )
	MAY ( description ) )

objectclass ( 1.3.6.1.1.1.2.4 NAME 'ipProtocol'
	DESC 'Abstraction of an IP protocol'
	SUP top STRUCTURAL
	MUST ( cn $ ipProtocolNumber $ description )
	MAY description )

objectclass ( 1.3.6.1.1.1.2.5 NAME 'oncRpc'
	DESC 'Abstraction of an ONC/RPC binding'
	SUP top STRUCTURAL
	MUST ( cn $ oncRpcNumber $ description )
	MAY description )

objectclass ( 1.3.6.1.1.1.2.6 NAME 'ipHost'
	DESC 'Abstraction of a host, an IP device'
	SUP top AUXILIARY
	MUST ( cn $ ipHostNumber )
	MAY ( l $ description $ manager ) )

objectclass ( 1.3.6.1.1.1.2.7 NAME 'ipNetwork'
	DESC 'Abstraction of an IP network'
	SUP top STRUCTURAL
	MUST ( cn $ ipNetworkNumber )
	MAY ( ipNetmaskNumber $ l $ description $ manager ) )

objectclass ( 1.3.6.1.1.1.2.8 NAME 'nisNetgroup'
	DESC 'Abstraction of a netgroup'
	SUP top STRUCTURAL
	MUST cn
	MAY ( nisNetgroupTriple $ memberNisNetgroup $ description ) )

objectclass ( 1.3.6.1.1.1.2.9 NAME 'nisMap'
	DESC 'A generic abstraction of a NIS map'
	SUP top STRUCTURAL
	MUST nisMapName
	MAY description )

objectclass ( 1.3.6.1.1.1.2.10 NAME 'nisObject'
	DESC 'An entry in a NIS map'
	SUP top STRUCTURAL
	MUST ( cn $ nisMapEntry $ nisMapName )
	MAY description )

objectclass ( 1.3.6.1.1.1.2.11 NAME 'ieee802Device'
	DESC 'A device with a MAC address'
	SUP top AUXILIARY
	MAY macAddress )

objectclass ( 1.3.6.1.1.1.2.12 NAME 'bootableDevice'
	DESC 'A device with boot parameters'
	SUP top AUXILIARY
	MAY ( bootFile $ bootParameter ) )

EOF

cat > /etc/ldap/slapd.conf <<"EOF"
include /etc/ldap/schema/core.schema
include /etc/ldap/schema/cosine.schema
include /etc/ldap/schema/inetorgperson.schema
include /etc/ldap/schema/nis.schema
include /etc/ldap/schema/groupofentries.schema
include /etc/ldap/schema/kerberos.schema

pidfile /var/run/slapd/slapd.pid
argsfile /var/run/slapd/slapd.args

modulepath /usr/lib/ldap
moduleload back_mdb

#authz-regexp 
#  uid=.*/admin,cn=gss.*,cn=auth
#  cn=admin,dc=example,dc=com

authz-regexp
  uid=.*/admin,cn=gss.*,cn=auth cn=admin,dc=example,dc=com
authz-regexp
  "uid=(.*),cn=gss.*,cn=auth"
  ldap:///dc=example,dc=com??sub?(krbPrincipalName=$1@EXAMPLE.COM)

database mdb
suffix dc=example,dc=com
access to attrs=userPassword,shadowLastChange
   by dn.exact="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
   write
   by group/groupOfEntries="cn=LDAP Read Write,ou=groups,dc=example,dc=com" write
   by group/groupOfEntries="cn=LDAP Read Only,ou=groups,dc=example,dc=com"  read
   by self write
   by anonymous auth
   by * none
access to attrs=cn,dc,gecos,gidNumber,homeDirectory,loginShell,member,memberUid,objectClass,ou,sn,uid,uidNumber,uniqueMember,entry
   by dn.exact="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
   write
   by group/groupOfEntries="cn=LDAP Read Write,ou=groups,dc=example,dc=com" write
   by group/groupOfEntries="cn=LDAP Read Only,ou=groups,dc=example,dc=com"  read
   by users read
   by anonymous auth
   by * none

access to dn.base=""
   by dn.exact="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
   write
   by group/groupOfEntries="cn=LDAP Read Write,ou=groups,dc=example,dc=com" write
   by group/groupOfEntries="cn=LDAP Read Only,ou=groups,dc=example,dc=com"  read
   by * read

access to *
   by dn.exact="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
   write
   by group/groupOfEntries="cn=LDAP Read Write,ou=groups,dc=example,dc=com" write
   by group/groupOfEntries="cn=LDAP Read Only,ou=groups,dc=example,dc=com"  read
   by * none

index cn eq
index uid eq
index uidNumber eq
index gidNumber eq
index krbPrincipalName eq
Index krbPwdPolicyReference eq

EOF


cat /root/example.com.ldif | sed -e 's/^objectClass: posixGroup$/objectClass: groupOfEntries\nobjectClass: posixGroup/' \
  | grep -v ^structuralObjectClass: > /root/example.com.ldif.new 
rm /var/lib/ldap/*
slapadd < /root/example.com.ldif.new
chown openldap:openldap /var/lib/ldap/*
systemctl start slapd.service

systemctl start slapd.service 

sleep 3

cat > /tmp/newentries.ldif <<"EOF"
dn: cn=admin,dc=example,dc=com
objectClass: organizationalRole
objectClass: simpleSecurityObject
cn: admin
userPassword: {SSHA}vfvtifa7F+Vgx39Fxe6lqRPvOc+koXgN

dn: cn=LDAP Read Write,ou=groups,dc=example,dc=com
objectClass: groupOfEntries
cn: LDAP Read Write
member: cn=admin,dc=example,dc=com

dn: cn=LDAP Read Only,ou=groups,dc=example,dc=com
objectClass: groupOfEntries
cn: LDAP Read Only
EOF

ldapadd -H ldapi:/// -Y EXTERNAL -f /tmp/newentries.ldif

systemctl restart slapd.service
