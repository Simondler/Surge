#!/bin/bash

set -e

SSH_DIR="$HOME/.ssh"
KEY_FILE="$SSH_DIR/id_ed25519"
PUB_KEY_FILE="$KEY_FILE.pub"
AUTH_KEYS="$SSH_DIR/authorized_keys"

echo "===== SSH Key Setup Start ====="

# 1. 创建 .ssh 目录
if [ ! -d "$SSH_DIR" ]; then
    echo "Creating ~/.ssh directory..."
    mkdir -p "$SSH_DIR"
fi

# 2. 生成密钥（如果不存在）
if [ ! -f "$KEY_FILE" ]; then
    echo "Generating ed25519 SSH key..."
    ssh-keygen -t ed25519 -f "$KEY_FILE" -N ""
else
    echo "SSH key already exists, skipping generation."
fi

# 3. 写入 authorized_keys（避免重复）
if ! grep -q -f "$PUB_KEY_FILE" "$AUTH_KEYS" 2>/dev/null; then
    echo "Adding public key to authorized_keys..."
    cat "$PUB_KEY_FILE" >> "$AUTH_KEYS"
else
    echo "Public key already in authorized_keys."
fi

# 4. 权限修正
echo "Fixing permissions..."
chmod 700 "$SSH_DIR"
chmod 600 "$AUTH_KEYS"
chmod 600 "$KEY_FILE"
chmod 644 "$PUB_KEY_FILE"

# 5. 重启 SSH 服务（自动识别系统）
echo "Restarting SSH service..."
if systemctl list-units --type=service | grep -q sshd; then
    sudo systemctl restart sshd
elif systemctl list-units --type=service | grep -q ssh; then
    sudo systemctl restart ssh
else
    echo "⚠️ Could not detect SSH service name. Restart manually if needed."
fi

echo "===== Done! SSH key authentication is ready. ====="