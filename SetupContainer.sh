#!/bin/sh

# ensure prereqs are met at this point, install with RUN in Dockerfile, these are for ubuntu 24.x
# wget curl unzip libc6 libgcc1 libgcc-s1 libgssapi-krb5-2 libicu74 liblttng-ust1 libssl3 libstdc++6 libunwind8 zlib1g openssl
#apt update
#apt install acl -y
# pwsh latest arm64
pwshurl=$(curl https://api.github.com/repos/PowerShell/PowerShell/releases/latest | grep -oP 'https://github.com/PowerShell/PowerShell/releases/download/.*linux-arm64.tar.gz' | head -1)
#wget $pwshurl
echo "Downloading latest powershell core"
curl -L -o /tmp/powershell.tar.gz $pwshurl
mkdir -p /opt/microsoft/powershell/7
#mkdir powershell
#pwshtar=$(ls | grep -oP 'powershell.*-linux-arm64.tar.gz' | head -1)
#tar -xvf $pwshtar -C ./powershell --no-same-owner
#tar zxf $pwshtar -C /opt/microsoft/powershell/7 --no-same-owner
tar zxf pwsh.tar.gz -C /opt/microsoft/powershell/7
#ln -s ./powershell/pwsh /usr/bin/pwsh
chmod +x /opt/microsoft/powershell/7/pwsh
#chmod +x ./powershell/pwsh
ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# powershell universal latest arm64
echo "Downloading latest powershell universal v5"
version=$(curl 'https://powershelluniversal.com/downloads' | grep -oP 'PowerShell Universal 5.*' | tr -dc '[. [:digit:]]' | head -1 | awk '{$1=$1};1')
curl -L https://powershelluniversal.com/download/psu/linux-arm64/$version --output psu.zip
unzip psu.zip -d /opt/psuniversal
PSU_PATH="/opt/psuniversal"
PSU_EXEC="${PSU_PATH}/Universal.Server"
PSU_SERVICE="psuniversal"
PSU_USER="psuniversal"
useradd $PSU_USER -m
echo "Creating $PSU_PATH and granting access to user $USER"
if [ ! -f $PSU_PATH ]; then
  mkdir $PSU_PATH
fi
chown $PSU_USER -R $PSU_PATH
chown $PSU_USER -R "/home/psuniversal/"
chown $PSU_USER -R "/opt/microsoft/powershell/"
#setfacl -m "u:${USER}:rwx" "/home/psuniversal/.PowerShellUniversal/"
#setfacl -m "u:${USER}:rwx" $PSU_PATH
echo "Make $PSU_EXEC executable"
chmod +x $PSU_EXEC

# import cert from storage mount
if [ -f "/root/certificate.cer" ]; then
  openssl x509 -inform DER -in /root/certificate.cer -out certificate.crt
  mv certificate.crt /usr/share/ca-certificates/
  chmod 644 /usr/share/ca-certificates/certificate.crt
  dpkg-reconfigure ca-certificates
  update-ca-certificates
fi

echo "start psu server as user $USER"
runuser -u $PSU_USER -- ./opt/psuniversal/Universal.Server
