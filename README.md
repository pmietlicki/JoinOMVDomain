# JoinOMVDomain
Script to integrate OpenMediaVault 3, 4 and 5 in the domain

With this script you will be able to add OpenMediaVault to a Samba4 or Windows Server Domain, on Windows Server it was homologated in 2008R2 and 2012R2 but it should work with any version of Windows Server.

# Use
To use this script, just download the file, give execution permission and run it as root or sudo:

wget https://raw.githubusercontent.com/pmietlicki/JoinOMVDomain/master/JoinDC.sh
chmod +x JoinDC.sh
./JoinDC.sh

Follow instructions step by step and restart OpenMediaVault, after restarting, just go look at the Users menu of the tool and you will see that all users have been added !
