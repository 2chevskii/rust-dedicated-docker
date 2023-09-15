FROM ubuntu:22.04

RUN addgroup --gid 28000 rustds
RUN adduser --uid 28000 --gid 28000 rustds

# Install required packages
RUN <<EOF
  set -exu
  apt-get update
  apt-get install -y \
    libc6 \
    libgcc-s1 \
    libgssapi-krb5-2 \
    libicu70 \
    liblttng-ust1 \
    libssl3 \
    libstdc++6 \
    libunwind8 \
    zlib1g \
    openssl \
    iproute2 \
    ca-certificates \
    unzip \
    wget
EOF

# This is where the logs are written
ENV LOGFILE_PATH=/var/log/rust_ds/server.log

# Create directories for DepotDownloader, Rust server and Rust server logfile
RUN mkdir -pm 0755 /opt/depotdownloader /opt/rust_ds `dirname $LOGFILE_PATH`
RUN chown -R 28000:28000 /opt/depotdownloader /opt/rust_ds `dirname $LOGFILE_PATH`

USER 28000:28000

WORKDIR /opt/depotdownloader

# Download and extract DepotDownloader release
RUN wget https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_2.5.0/DepotDownloader-linux-x64.zip -O DepotDownloader-2.5.0-linux64.zip
RUN unzip DepotDownloader-2.5.0-linux64.zip
RUN chmod +x DepotDownloader

# Install Rust Dedicated (258550) using DepotDownloader

RUN ./DepotDownloader -app 258550 -dir /opt/rust_ds

WORKDIR /opt/rust_ds

# Copy entrypoint script
COPY --chown=28000:28000 bin/rust-server .

RUN chmod +x RustDedicated rust-server

ENV SERVER_PORT=28015
ENV RCON_PORT=28016
ENV SERVER_QUERYPORT=28017
ENV RUSTPLUS_PORT=28083

ENV SERVER_HOSTNAME="Dockerized Rust Dedicated Server"
ENV SERVER_DESCRIPTION="This server is running the 2chevskii/rust-ds docker image"
ENV SERVER_IDENTITY=rust_docker

ENV SERVER_LEVEL="Procedural Map"
ENV SERVER_WORLDSIZE=3000
ENV SERVER_MAPSEED=1337

ENV RCON_PASSWORD=changeme

ENV ADDITIONAL_CMD_ARGS=""

EXPOSE $SERVER_PORT $RCON_PORT $SERVER_QUERYPORT $RUSTPLUS_PORT

ENTRYPOINT ["rust-server"]
