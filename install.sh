#!/bin/bash

set -e

# 定义变量
DOWNLOAD_URL="https://dl.nssurge.com/snell/snell-server-v4.1.1-linux-amd64.zip"
INSTALL_PATH="/root/snell"
SERVICE_FILE="/etc/systemd/system/snell.service"


# 下载 snell

mkdir snell && cd snell
wget "$DOWNLOAD_URL"
#chmod +x x86_64-qbittorrent-nox

cat > /root/snell/snell.conf << EOF
[snell-server]
listen = 0.0.0.0:8443
dns = 1.1.1.1, 8.8.8.8
psk = AijHCeos15IvqDZTb1cJMX5GcgZzIVE
ipv6 = false
obfs = off
EOF

# 创建 Systemd 服务文件
cat << EOF > "$SERVICE_FILE"
[Unit]
Description=Snell Proxy Service
After=network.target

[Service]
Type=simple
User=root
Group=nogroup
LimitNOFILE=32768
ExecStart=/root/snell/snell-server -c /root/snell/snell.conf
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=snell-server

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl start snell.service
systemctl enable snell.service
