FROM ubuntu
USER root
RUN useradd psuniversal -m
WORKDIR /home/psuniversal
RUN apt-get update
RUN apt-get install apt-utils curl unzip libc6-dev libgcc1 libgcc-s1 libgssapi-krb5-2 libicu74 liblttng-ust1 libssl3 libstdc++6 libunwind8 zlib1g openssl ca-certificates gss-ntlmssp tzdata less locales --no-install-recommends -y
RUN pwshurl=$(curl https://api.github.com/repos/PowerShell/PowerShell/releases/latest | grep -oP 'https://github.com/PowerShell/PowerShell/releases/download/.*linux-arm64.tar.gz' | head -1); curl -L -o /tmp/powershell.tar.gz $pwshurl; mkdir -p /opt/microsoft/powershell/7; tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7; chmod +x /opt/microsoft/powershell/7/pwsh; ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
RUN version=$(curl 'https://powershelluniversal.com/downloads' | grep -oP 'PowerShell Universal 5.*' | tr -dc '[. [:digit:]]' | head -1 | awk '{$1=$1};1'); curl -L https://powershelluniversal.com/download/psu/linux-arm64/$version --output psu.zip; unzip psu.zip -d /opt/psuniversal
RUN chmod +x '/opt/psuniversal/Universal.Server'; chmod +x "/opt/psuniversal/Hosts/7.5/PowerShellUniversal.Host"; chmod +x "/opt/psuniversal/Universal.Agent"
#CMD curl https://raw.githubusercontent.com/serialscriptr/PSU5-ARM64/main/SetupContainer.sh | sh
ARG DEBIAN_FRONTEND=noninteractive
EXPOSE 5000/tcp
USER psuniversal
ENTRYPOINT ["./opt/psuniversal/Universal.Server"]
