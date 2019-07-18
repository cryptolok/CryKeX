![](https://github.com/cryptolok/CryKeX/raw/master/logo.png)

Properties:
* Cross-platform
* Minimalism
* Simplicity
* Interactivity
* Compatibility/Portability
* Application Independable
* Process Wrapping
* Process Injection

Dependencies:
* **Unix** - should work on any Unix-based OS
	- BASH - the whole script
	- root privileges (optional)

Limitations:
* AES and RSA keys only
* Fails most of the time for Firefox browser
* Won't work for disk encryption (LUKS) and PGP/GPG
* Needs proper user privileges and memory authorizations

# How it works

[Some](https://dfrws.org/sites/default/files/session-files/paper-the_persistence_of_memory_-_forensic_identification_and_extraction_of_cryptographic_keys.pdf) [work](https://www.scribd.com/doc/130070110/Extracting-Encryption-keys-from-RAM) has been already published regarding the subject of cryptograhic keys security within DRAM. Basically, we need to find something that looks like a key (entropic and specific length) and then confirm its nature by analyzing the memory structure around it (C data types).

The idea is to dump live memory of a process and use those techniques in order to find probable keys since, memory mapping doesn't change. Thanks-fully, tools exist for that purpose.

The script is not only capable of injecting into already running processes, but also wrapping new ones, by launching them separately and injecting shortly afterwards. This makes it capable of dumping keys from almost any process/binary on the system.

Of course, accessing a memory is limited by kernel, which means that you will still require privileges for a process.

Linux disk ecnryption (LUKS) uses anti-forensic [technique](https://gitlab.com/cryptsetup/cryptsetup/wikis/LUKS-standard/on-disk-format.pdf#4) in order to mitigate such issue, however, extracting keys from a whole memory is still possible.

Firefox browser uses somehow similar memory management, thus seems not to be affected.

Same goes for PGP/GPG.

Unfortunately, solutions like [Ansible](https://docs.ansible.com/ansible/latest/user_guide/vault.html) are affected.

## HowTo

Installing dependencies:
```bash
sudo apt install gdb aeskeyfind rsakeyfind || echo 'have you heard about source compiling?'
```


An interactive example for OpenSSL AES keys:
```bash
openssl aes-128-ecb -nosalt -out testAES.enc
```
Enter a password twice, then some text and before terminating:
```bash
CryKeX.sh openssl
```
Finally, press Ctrl+D 3 times and [check](http://aes.online-domain-tools.com/) the result.


OpenSSL RSA keys:
```bash
openssl genrsa -des3 -out testRSA.pem 2048
```
When prompted for passphrase:
```bash
CryKeX.sh openssl
```
Verify:
```bash
openssl rsa -noout -text -in testRSA.pem
```


Let's extract keys from SSH:
```bash
echo 'Ciphers aes256-gcm@openssh.com' >> /etc/ssh/sshd_config
ssh user@server
CryKeX.sh ssh
```

From OpenVPN:
```bash
echo 'cipher AES-256-CBC' >> /etc/openvpn/server.conf
openvpn yourConf.ovpn
sudo CryKeX.sh openvpn
```

TrueCrypt/VeraCrypt is also affected:
Select "veracrypt" file in VeraCrypt, mount with password "pass" and:
```bash
sudo CryKeX.sh veracrypt
```

Chromium-based browsers (thanks Google):
```bash
CryKeX.sh chromium
CryKeX.sh google-chrome
```

Despite Firefox not being explicitly affected, Tor Browser Bundle is still susceptible due to tunneling:
```bash
CryKeX.sh tor
```

As said, you can also wrap processes:
```bash
apt install libssl-dev
gcc -lcrypto cipher.c -o cipher
CryKeX.sh cipher
	wrap
	cipher
```

### Notes

Feel free to contribute and test other applications.

> "They key of persistence opens all door closed by resistence"

John Di Lemme
