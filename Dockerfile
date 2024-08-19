FROM ubuntu
RUN apt-get update
RUN apt-get install wget curl unzip libc6 libgcc1 libgcc-s1 libgssapi-krb5-2 libicu74 liblttng-ust1 libssl3 libstdc++6 libunwind8 zlib1g openssl -y
CMD curl https://raw.githubusercontent.com/serialscriptr/PSU5-ARM64/main/SetupContainer.sh | sh
