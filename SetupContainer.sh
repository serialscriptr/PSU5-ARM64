#!/bin/sh

# ensure prereqs are met at this point, install with RUN in Dockerfile, these are for ubuntu 24.x
# wget curl unzip libc6 libgcc1 libgcc-s1 libgssapi-krb5-2 libicu74 liblttng-ust1 libssl3 libstdc++6 libunwind8 zlib1g openssl

# pwsh latest arm64
pwshurl=$(curl https://api.github.com/repos/PowerShell/PowerShell/releases/latest | grep -oP 'https://github.com/PowerShell/PowerShell/releases/download/.*linux-arm64.tar.gz' | head -1)
wget $pwshurl
mkdir ~/powershell
pwshtar=$(ls | grep -oP 'powershell.*-linux-arm64.tar.gz' | head -1)
tar -xvf $pwshtar -C ~/powershell --no-same-owner
ln -s ~/powershell/pwsh /usr/bin/pwsh

# powershell universal latest arm64
#dlurl=$(curl 'https://ironmansoftware.com/powershell-universal/downloads' | grep -oP 'https://imsreleases.blob.core.windows.net/universal/production/.*linux-arm64.*.zip' | head -1)
curl -oL 'https://imsreleases.blob.core.windows.net/universal/production/5.0.5/Universal.linux-arm64.5.0.5.zip' > psuarm64.zip
unzip psuarm64.zip -d PSU

# fix issues reading module directory, idk what permissions are best
chmod 777 /root/.PowerShellUniversal

# import custom config from storage mount
if [ -f "/root/powershell.config.json" ]; then
  cp "/root/powershell.config.json" "/PSU/powershell.config.json"
fi

# import cert from storage mount
if [ -f "/root/certificate.cer" ]; then
  openssl x509 -inform DER -in /root/certificate.cer -out certificate.crt
  mv certificate.crt /usr/share/ca-certificates/
  chmod 644 /usr/share/ca-certificates/certificate.crt
  dpkg-reconfigure ca-certificates
  update-ca-certificates
fi

# run psu server
chmod +x ./PSU/Universal.Server
./PSU/Universal.Server
