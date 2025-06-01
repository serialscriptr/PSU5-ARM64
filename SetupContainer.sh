#!/bin/sh

# ensure prereqs are met at this point, install with RUN in Dockerfile, these are for ubuntu 24.x
# wget curl unzip libc6 libgcc1 libgcc-s1 libgssapi-krb5-2 libicu74 liblttng-ust1 libssl3 libstdc++6 libunwind8 zlib1g openssl

# pwsh latest arm64
pwshurl=$(curl https://api.github.com/repos/PowerShell/PowerShell/releases/latest | grep -oP 'https://github.com/PowerShell/PowerShell/releases/download/.*linux-arm64.tar.gz' | head -1)
wget $pwshurl
mkdir powershell
pwshtar=$(ls | grep -oP 'powershell.*-linux-arm64.tar.gz' | head -1)
tar -xvf $pwshtar -C ./powershell --no-same-owner
ln -s ./powershell/pwsh /usr/bin/pwsh
chmod +x ./powershell/pwsh
chmod +x /usr/bin/pwsh

# powershell universal latest arm64
version=$(curl 'https://powershelluniversal.com/downloads' | grep -oP 'PowerShell Universal 5.*' | tr -dc '[. [:digit:]]' | head -1 | awk '{$1=$1};1')
curl -L https://powershelluniversal.com/download/psu/linux-arm64/$version --output psu.zip
unzip psu.zip -d /opt/psuniversal
PSU_PATH="/opt/psuniversal"
PSU_EXEC="${PSU_PATH}/Universal.Server"
PSU_SERVICE="psuniversal"
PSU_USER="psuniversal"
echo "Creating $PSU_PATH and granting access to $USER"
mkdir $PSU_PATH
setfacl -m "u:${USER}:rwx" $PSU_PATH

echo "Creating user $PSU_USER and making it the owner of $PSU_PATH"
useradd $PSU_USER -m
chown $PSU_USER -R $PSU_PATH
echo "Make $PSU_EXEC executable"
chmod +x $PSU_EXEC

# if /root/.PowerShellUniversal/Repository doesnt exist create it
if [ -f "/root/.PowerShellUniversal/Repository" ]; then
  chown $PSU_USER -R /root/.PowerShellUniversal/Repository
fi

# import cert from storage mount
if [ -f "/root/certificate.cer" ]; then
  openssl x509 -inform DER -in /root/certificate.cer -out certificate.crt
  mv certificate.crt /usr/share/ca-certificates/
  chmod 644 /usr/share/ca-certificates/certificate.crt
  dpkg-reconfigure ca-certificates
  update-ca-certificates
fi

echo "Creating service configuration"
cat <<EOF > ~/$PSU_SERVICE.service
[Unit]
Description=PowerShell Universal
[Service]
ExecStart=$PSU_EXEC
SyslogIdentifier=psuniversal
User=$PSU_USER
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF

echo "Creating and starting service"
cp -f ~/$PSU_SERVICE.service /etc/systemd/system
systemctl daemon-reload
systemctl enable $PSU_SERVICE
systemctl start $PSU_SERVICE
systemctl status $PSU_SERVICE --no-pager
