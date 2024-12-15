#!/bin/bash

# 日志文件路径
LOG_FILE="/root/update_and_clean.log"

# 设置无人值守模式
export DEBIAN_FRONTEND=noninteractive

# 清空日志文件，确保每次运行只保留当前日志
> "$LOG_FILE"

# 记录日志函数
log_message() {
    echo "[ $(date +"%Y-%m-%d %H:%M:%S") ] $1" | tee -a "$LOG_FILE"
}

log_message "开始系统更新和清理流程..."

# 检查并安装 deborphan 工具
log_message "检查并安装 deborphan 工具..."
if ! command -v deborphan &> /dev/null; then
    apt-get update && apt-get install -y deborphan
    if [[ $? -eq 0 ]]; then
        log_message "deborphan 安装成功。"
    else
        log_message "deborphan 安装失败，请检查！"
        exit 1
    fi
else
    log_message "deborphan 已安装。"
fi

# 更新系统并安装内核依赖
log_message "更新系统和内核依赖..."
apt-get update && apt-get -y upgrade
if [[ $? -eq 0 ]]; then
    log_message "系统和内核依赖更新完成。"
else
    log_message "系统更新失败，请检查！"
    exit 1
fi

# 检查是否有新的内核安装
log_message "检查是否有新内核安装..."
current_kernel=$(uname -r)
latest_installed_kernel=$(dpkg --list | grep linux-image | awk '{print $2}' | sort -V | tail -n 1)

log_message "当前运行内核: $current_kernel"
log_message "最新安装内核: $latest_installed_kernel"

new_kernel_installed=false
if [[ "$latest_installed_kernel" != *"$current_kernel"* ]]; then
    new_kernel_installed=true
    log_message "检测到新内核: $latest_installed_kernel"
else
    log_message "没有新内核需要重启。"
fi

# 自动清理系统中不需要的依赖包
log_message "清理系统中不需要的依赖包..."
apt-get -y autoremove --purge
if [[ $? -eq 0 ]]; then
    log_message "系统垃圾依赖清理完成。"
else
    log_message "清理垃圾依赖失败，请检查！"
fi

# 卸载不需要的旧内核
log_message "检查并卸载旧内核..."
old_kernels=$(dpkg --list | grep linux-image | awk '{print $2}' | grep -v "$current_kernel" | grep -v "$(echo $latest_installed_kernel | sed 's/linux-image-//')")

if [[ -n "$old_kernels" ]]; then
    log_message "待卸载的旧内核列表：$old_kernels"
    for kernel in $old_kernels; do
        log_message "卸载旧内核: $kernel..."
        apt-get -y purge "$kernel"
        if [[ $? -eq 0 ]]; then
            log_message "旧内核 $kernel 卸载成功。"
        else
            log_message "旧内核 $kernel 卸载失败，请检查！"
        fi
    done
else
    log_message "没有旧内核需要卸载。"
fi

# 更新 GRUB 配置
log_message "更新 GRUB 配置..."
DEBIAN_FRONTEND=noninteractive apt-get install -y --reinstall grub-pc grub-pc-bin grub-common grub2-common
update-grub
if [[ $? -eq 0 ]]; then
    log_message "GRUB 配置更新完成。"
else
    log_message "GRUB 配置更新失败，请检查！"
fi

# 清理垃圾文件
log_message "开始清理系统垃圾..."

# 1. 清理 APT 缓存
log_message "清理 APT 缓存文件..."
apt-get clean

# 2. 清理临时文件
log_message "清理临时文件 (/tmp, /var/tmp)..."
rm -rf /tmp/* /var/tmp/*

# 3. 清理系统日志
log_message "清理系统日志文件..."
find /var/log -type f -name "*.log" -delete

# 4. 清理已卸载软件的残留配置
log_message "清理已卸载软件的残留配置..."
residual_packages=$(dpkg -l | grep '^rc' | awk '{print $2}')
if [[ -n "$residual_packages" ]]; then
    echo "$residual_packages" | xargs dpkg --purge
    log_message "残留配置清理完成。"
else
    log_message "没有残留配置需要清理。"
fi

# 5. 清理用户缓存
log_message "清理用户缓存..."
rm -rf ~/.cache/*
for user in /home/*; do rm -rf "$user/.cache/*"; done

# 6. 清理孤立的包依赖
log_message "清理孤立的包依赖..."
deborphan | xargs apt-get -y remove --purge

# 7. 清理未使用的 Docker 数据
log_message "清理未使用的 Docker 数据..."
if command -v docker &> /dev/null; then
    docker system prune -af
    log_message "Docker 数据清理完成。"
else
    log_message "Docker 未安装，跳过清理。"
fi

log_message "垃圾清理完成！"

# 如果检测到新内核，重启系统
if $new_kernel_installed; then
    log_message "检测到新内核，准备重启系统以应用更改..."
    reboot
else
    log_message "无需重启系统。"
fi

log_message "系统更新和清理流程完成。"