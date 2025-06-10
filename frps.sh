#!/bin/bash

set -e

# 1. 获取系统架构
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
    armv7l)
        ARCH="arm"
        ;;
    i386 | i686)
        ARCH="386"
        ;;
    *)
        echo "不支持的架构: $ARCH"
        exit 1
        ;;
esac

# 2. 获取最新版本号
echo "获取最新版本..."
VERSION=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep tag_name | cut -d '"' -f 4)

# 3. 下载对应架构的压缩包
FRP_NAME="frp_${VERSION#v}_linux_$ARCH"
FRP_FILE="$FRP_NAME.tar.gz"
DOWNLOAD_URL="https://github.com/fatedier/frp/releases/download/${VERSION}/${FRP_FILE}"

echo "下载: $DOWNLOAD_URL"
curl -LO "$DOWNLOAD_URL"

# 4. 解压并移动
tar -zxf "$FRP_FILE"
mkdir -p /etc/frps
cp "$FRP_NAME/frps" /etc/frps/
cp "$FRP_NAME/frps.toml" /etc/frps/ 2>/dev/null || true

# 5. 创建默认配置文件
cat <<EOF >/etc/frps/frps.toml
bindPort = 11111
kcpBindPort = 11111
auth.token = "W7AMIhMUk62CuUZAK9MH4aPEZr4I349h2O7qZfJVOEvgkHtuxWgwBUkLuOwuYtSp"


vhostHTTPPort = 80
vhostHTTPSPort = 443
#subdomainHost = "*.ilmz.net"

#webServer.addr = "0.0.0.0"            
#webServer.port = 7500
#webServer.user = "admin"  
#webServer.password = "wqnmlgb@V587"

log.to = "/etc/frps/frps.log"
log.level = "info"
log.maxDays = 3
log.disablePrintColor = false
EOF

# 6. 创建 systemd 服务文件
cat <<EOF >/etc/systemd/system/frps.service
[Unit]
Description = frp server
After = network.target syslog.target
Wants = network.target

[Service]
Type = simple
ExecStart = /etc/frps/frps -c /etc/frps/frps.toml

[Install]
WantedBy = multi-user.target
EOF

# 7. 启动服务
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable frps
systemctl start frps

echo "frps 部署完成 ✅"
echo "配置文件路径：/etc/frps/frps.toml"
