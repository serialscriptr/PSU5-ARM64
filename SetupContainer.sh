#!/bin/sh

# ensure prereqs are met at this point, install with RUN in Dockerfile, these are for ubuntu 24.x
# wget curl unzip libc6 libgcc1 libgcc-s1 libgssapi-krb5-2 libicu74 liblttng-ust1 libssl3 libstdc++6 libunwind8 zlib1g openssl

# pwsh latest arm64
pwshurl=$(curl https://api.github.com/repos/PowerShell/PowerShell/releases/latest | grep -oP 'https://github.com/PowerShell/PowerShell/releases/download/.*linux-arm64.tar.gz' | head -1)
echo "Downloading latest powershell core"
curl -L -o /tmp/powershell.tar.gz $pwshurl
mkdir -p /opt/microsoft/powershell/7
tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7
chmod +x /opt/microsoft/powershell/7/pwsh
ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# powershell universal latest arm64
echo "Downloading latest powershell universal v5"
#version=$(curl 'https://powershelluniversal.com/downloads' | grep -oP 'PowerShell Universal 5.*' | tr -dc '[. [:digit:]]' | head -1 | awk '{$1=$1};1')
#curl -L https://powershelluniversal.com/download/psu/linux-arm64/$version --output psu.zip
curl -L https://powershelluniversal.com/download/psu/linux-arm64/4.5.4 --output psu.zip
unzip psu.zip -d /opt/psuniversal
PSU_PATH="/opt/psuniversal"
PSU_EXEC="${PSU_PATH}/Universal.Server"
PSU_SERVICE="psuniversal"
PSU_USER="psuniversal"
useradd $PSU_USER -m
echo "Creating $PSU_PATH and granting access to user $USER"
chown $PSU_USER -R $PSU_PATH
chown $PSU_USER -R "/home/psuniversal/"
chown $PSU_USER -R "/opt/microsoft/powershell/"
echo "Make $PSU_EXEC executable"
chmod +x $PSU_EXEC
echo "Make PSU included pwsh executable"
chmod +x "${PSU_PATH}/Hosts/7.5/PowerShellUniversal.Host"
chmod +x "${PSU_PATH}/Universal.Agent"

# import cert from storage mount
if [ -f "/home/psuniversal/certificate.cer" ]; then
  openssl x509 -inform DER -in /home/psuniversal/certificate.cer -out certificate.crt
  mv certificate.crt /usr/share/ca-certificates/
  chmod 644 /usr/share/ca-certificates/certificate.crt
  dpkg-reconfigure ca-certificates
  update-ca-certificates
fi

# use custom appsettings if found
if [ -f "/home/psuniversal/appsettings.json" ]
then
  echo "start psu server as user $USER using custom appsettings from storage"
  runuser -u $PSU_USER -- ./opt/psuniversal/Universal.Server --appsettings /home/psuniversal/appsettings.json
else
  echo "start psu server as user $USER"
  runuser -u $PSU_USER -- ./opt/psuniversal/Universal.Server
fi
