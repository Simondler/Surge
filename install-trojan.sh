#!/bin/bash

set -e

echo "=== Trojan-Go 一键部署脚本 ==="

# 检查是否以 root 身份运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 用户运行该脚本！"
    exit 1
fi

# 定义必要的工具列表
required_tools=("wget" "curl" "tar" "socat" "unzip")

# 检测并安装所需工具
echo "检测所需工具是否已安装..."
install_tools() {
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "未检测到 $tool，正在安装..."
            if [[ -x "$(command -v apt)" ]]; then
                apt install -y "$tool"
            elif [[ -x "$(command -v yum)" ]]; then
                yum install -y "$tool"
            else
                echo "无法确定包管理器，请手动安装 $tool！"
                exit 1
            fi
        else
            echo "$tool 已安装，跳过。"
        fi
    done
}
install_tools


# 检测平台架构
echo "检测系统架构..."
arch=$(uname -m)
if [[ "$arch" == "x86_64" ]]; then
    platform="amd64"
elif [[ "$arch" == "aarch64" ]]; then
    platform="arm"
else
    echo "不支持的架构: $arch"
    exit 1
fi
echo "检测到架构: $platform"

# 创建必要的目录
mkdir -p /root/trojan-go
cd /root/trojan-go

# 下载 Trojan-Go
echo "下载 Trojan-Go ($platform)..."
# latest_version=$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest" | grep "tag_name" | cut -d '"' -f 4)
wget -q "https://github.com/p4gefau1t/trojan-go/releases/download/v0.10.6/trojan-go-linux-${platform}.zip" -O trojan-go.zip
unzip -q trojan-go.zip && rm -f trojan-go.zip


# 创建配置文件
echo "创建配置文件..."
cat > /root/trojan-go/config.json <<EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 44443,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "WqnmlgbV587"
    ],
    "ssl": {
        "cert": "/etc/key/server.crt",
        "key": "/etc/key/server.key",
        "fallback_addr":"127.0.0.1",
        "fallback_port":80
    }
}
EOF


# 创建系统服务文件
echo "创建系统服务文件..."
cat > /etc/systemd/system/trojan-go.service <<EOF
[Unit]
Description=Trojan-Go Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/root/trojan-go/trojan-go -config /root/trojan-go/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 启动服务并设置开机自启
echo "启动 Trojan-Go 服务并设置开机自启..."
systemctl daemon-reload
systemctl enable trojan-go
systemctl start trojan-go

# 检查服务状态
if systemctl is-active --quiet trojan-go; then
    echo "Trojan-Go 部署成功并已启动！"

else
    echo "Trojan-Go 启动失败，请检查日志！"
    journalctl -u trojan-go
fi