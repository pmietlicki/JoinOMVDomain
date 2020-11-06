#!/bin/bash
# Created by: Tácio de Jesus Andrade - tacio@multiti.com.br
# Date: 22-12-2019
# Goal: Script to integrate OpenMediaVault 3, 4 or 5 inside an AD domain
# Information: Before executing this script check if the DNS server is the Domain Controller and if it pings to the domain.local

echo "Enter domain name Ex. EXAMPLE.LOCAL: " ; read DOMAIN
echo "Enter the name of your Domain Controller Ex. dc01.example.local: " ; read DC
echo "Please enter a domain admin login to use: " ; read DOMAINUSER
# Install the necessary packages
apt-get install krb5-user krb5-config winbind samba samba-common smbclient cifs-utils libpam-krb5 libpam-winbind libnss-winbind

# Backup Kerberos file
cp /etc/krb5.conf /etc/krb5.conf.ori

# Correct Kerberos file
echo "[logging]
Default = FILE:/var/log/krb5.log

[libdefaults]
ticket_lifetime = 24000
clock-skew = 300
default_realm = $DOMAIN
dns_lookup_realm = true
dns_lookup_kdc = true

[realms]
`echo $DOMAIN`  = {
kdc = $DC
default_domain = `echo $DOMAIN | tr 'A-Z' 'a-z'`
admin_server = $DC
}

[domain_realm]
.`echo $DOMAIN | tr 'A-Z' 'a-z'` = $DOMAIN
`echo $DOMAIN | tr 'A-Z' 'a-z'` = $DOMAIN

[login]
krb4_convert = true
krb4_get_tickets = false" > /etc/krb5.conf

# Corrige o problema de resolução de DNS e faz os usuários do winbind poderem logar
cp /etc/nsswitch.conf /etc/nsswitch.conf.ori
echo "passwd:         compat winbind
group:          compat winbind
shadow:         files
gshadow:        files

# hosts:          files mdns4_minimal [NOTFOUND=return] dns myhostname
hosts:          dns files mdns4_minimal [NOTFOUND=return] myhostname
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis" > /etc/nsswitch.conf

# Test if the connection to the DC is okay
echo "


Enter the domain Administrator password" 
kinit $DOMAINUSER
klist

# Samba Extras to integrate to the domain
echo "Enable samba and add it to the OpenMediaVault Samba Extras field through the graphical interface:

security = ads
realm = `echo $DOMAIN`
client signing = yes
client use spnego = yes
kerberos method = secrets and keytab
obey pam restrictions = yes
protocol = SMB3
netbios name = `hostname | cut -d '.' -f1`
password server = *
encrypt passwords = yes
winbind uid = 10000-20000
winbind gid = 10000-20000
winbind enum users = yes
winbind enum groups = yes
winbind use default domain = yes
winbind refresh tickets = yes
idmap config `echo $DOMAIN | cut -d '.' -f1` : backend  = rid
idmap config `echo $DOMAIN | cut -d '.' -f1` : range = 1000-9999
Idmap config *:backend = tdb 
idmap config *:range = 85000-86000 
template shell    = /bin/sh
lanman auth = no
ntlm auth = yes
client lanman auth = no
client plaintext auth = No
client NTLMv2 auth = Yes" > /tmp/smb.tmp
cat /tmp/smb.tmp

# Type Enter to continue configuration
echo "


After making the changes, type Enter: " ; read ENTER

# Integration to the domain
echo "


Enter the domain Administrator password to integrate OpenMediaVault into DC" 
net ads join -U $DOMAINUSER
net ads testjoin

# Reinicia os serviços
/etc/init.d/smbd restart
/etc/init.d/winbind restart

# Lista os usuários do domínio
sleep 3
wbinfo -u

echo "Reboot the server and check if users have been added to the graphical interface successfully!"
