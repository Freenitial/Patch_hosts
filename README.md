# Patch hosts
Add / Remove entry from hosts file

## Description
`patch_hosts.bat` is a Windows batch script that adds or removes entries in the system `hosts` file.  
It supports multiple domains, forces the IP address to `0.0.0.0` when blocking, and can restore removed lines with the `/remove` option.

## Features
- Add or remove several domains in a single command  
- Automatically replace any existing IP with `0.0.0.0`  
- Skip lines that start with `#` (comments)  
- Flush the DNS cache after changes  
- Stop and warn if the script is not run with administrator privileges

## Usage
```cmd
:: Block two domains
patch_hosts.bat example.com example.org

:: Remove blocking
patch_hosts.bat example.com example.org /remove
