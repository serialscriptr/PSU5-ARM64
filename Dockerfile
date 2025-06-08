FROM ubuntu
RUN apt-get update
RUN apt-get install apt-utils curl unzip libc6-dev libgcc1 libgcc-s1 libgssapi-krb5-2 libicu74 liblttng-ust1 libssl3 libstdc++6 libunwind8 zlib1g openssl ca-certificates gss-ntlmssp tzdata less locales --no-install-recommends -y
CMD curl https://raw.githubusercontent.com/serialscriptr/PSU5-ARM64/main/SetupContainer.sh | sh
ARG DEBIAN_FRONTEND=noninteractive
EXPOSE 5000/tcp
USER psuniversal
ENTRYPOINT runuser -u psuniversal -- ./opt/psuniversal/Universal.Server
