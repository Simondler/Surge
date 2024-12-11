#!/bin/bash

# 检查系统架构
ARCH=$(uname -m)
CLOUDREVE_VERSION="3.8.3"  # 替换为您需要的版本

# 确定下载链接
if [[ "$ARCH" == "x86_64" ]]; then
    DOWNLOAD_URL="https://github.com/cloudreve/Cloudreve/releases/download/${CLOUDREVE_VERSION}/cloudreve_${CLOUDREVE_VERSION}_linux_amd64.tar.gz"
elif [[ "$ARCH" == "aarch64" ]]; then
    DOWNLOAD_URL="https://github.com/cloudreve/Cloudreve/releases/download/${CLOUDREVE_VERSION}/cloudreve_${CLOUDREVE_VERSION}_linux_arm64.tar.gz"
else
    echo "不支持的架构：$ARCH"
    exit 1
fi

# 创建安装目录
INSTALL_DIR="/opt/cloudreve"
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
fi

# 进入安装目录
cd "$INSTALL_DIR" || exit

# 下载 Cloudreve
echo "正在下载 Cloudreve..."
wget -O cloudreve.tar.gz "$DOWNLOAD_URL"
if [ $? -ne 0 ]; then
    echo "下载失败，请检查网络或下载链接。"
    exit 1
fi

# 解压文件
echo "正在解压 Cloudreve..."
tar -zxvf cloudreve.tar.gz
rm -f cloudreve.tar.gz

# 设置执行权限
chmod +x cloudreve

# 创建必要的目录
mkdir -p uploads config db

# 创建系统服务
echo "正在创建系统服务..."
cat <<EOF > /etc/systemd/system/cloudreve.service
[Unit]
Description=Cloudreve Service
After=network.target

[Service]
Type=simple
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/cloudreve
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# 重新加载服务
systemctl daemon-reload

# 启动并设置开机自启
echo "启动 Cloudreve 服务..."
systemctl start cloudreve
systemctl enable cloudreve

echo "Cloudreve 已成功安装并运行！"
echo "您可以通过以下地址访问 Cloudreve："
echo "http://$(curl -s ifconfig.me):5212"

