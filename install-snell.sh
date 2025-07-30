#!/bin/bash

# 检查是否以 root 用户运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本！"
  exit 1
fi

# 检测系统架构
ARCH=$(uname -m)

case "$ARCH" in
"x86_64")
  ARCH_TYPE="amd64"
  ;;
"aarch64")
  ARCH_TYPE="aarch64"
  ;;
*)
  echo "未支持的系统架构: $ARCH"
  exit 1
  ;;
esac

echo "检测到系统架构: $ARCH_TYPE"


# 设置变量
SNELL_VERSION="v5.0.0" # 修改为您想要的版本
SNELL_URL="https://dl.nssurge.com/snell/snell-server-${SNELL_VERSION}-linux-${ARCH_TYPE}.zip"
SNELL_DIR="/etc/snell"
SNELL_CONFIG="/etc/snell/snell.conf"
SNELL_SERVICE="/etc/systemd/system/snell.service"

#更新软件
# apt update
# apt full-upgrade -y
apt install unzip

# 创建工作目录
mkdir -p $SNELL_DIR

# 下载 Snell
echo "正在下载 Snell..."
wget -q --show-progress -O snell.zip $SNELL_URL
if [ $? -ne 0 ]; then
  echo "下载 Snell 失败，请检查网络或版本号是否正确。"
  exit 1
fi

# 解压文件
echo "正在解压 Snell..."
unzip -o snell.zip -d $SNELL_DIR
if [ $? -ne 0 ]; then
  echo "解压失败，请检查解压工具是否已安装。"
  exit 1
fi
rm snell.zip
chmod +x $SNELL_DIR/snell-server

# 创建 Snell 配置文件
echo "正在创建配置文件..."
cat > $SNELL_CONFIG << EOF
[snell-server]
listen = ::0:8443
dns = 1.1.1.1, 8.8.8.8
psk = AijHCeos15IvqDZTb1cJMX5GcgZzIVE
ipv6 = true
tfo = false
obfs = off
EOF

# 创建 Systemd 服务文件
echo "正在配置 Systemd 服务..."
cat > $SNELL_SERVICE << EOF
[Unit]
Description=Snell Proxy Service
After=network.target

[Service]
Type=simple
ExecStart=$SNELL_DIR/snell-server -c $SNELL_CONFIG
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 重新加载 Systemd 配置并启动 Snell 服务
echo "正在启动 Snell 服务..."
systemctl daemon-reload
systemctl enable snell
systemctl start snell

# 检查服务状态
if systemctl is-active --quiet snell; then
  echo "Snell 已成功安装并运行！"
  echo "配置文件位置：$SNELL_CONFIG"
else
  echo "Snell 服务启动失败，请检查日志：journalctl -u snell"
fi

# 定义需要检查的参数
PARAMS=("net.core.default_qdisc = fq" "net.ipv4.tcp_congestion_control = bbr" "net.ipv4.tcp_fastopen = 0" "net.ipv4.tcp_ecn = 1" "vm.swappiness = 0")

# 遍历参数并检查是否存在
for PARAM in "${PARAMS[@]}"; do
  if grep -q "^$PARAM" /etc/sysctl.conf; then
    echo "参数已存在: $PARAM"
  else
    echo "添加参数: $PARAM"
    echo "$PARAM" >> /etc/sysctl.conf
  fi
done

# 应用配置
echo "应用 sysctl 配置..."
sysctl -p

echo "操作完成！"


if lsmod | grep bbr; then
   echo "BBR安装成功"
fi
