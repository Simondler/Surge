#!/bin/bash
sudo apt install fail2ban

sudo cat > cat /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = -1
findtime = -1
maxretry = 3
backend = auto
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true
port = 10923
logpath = /var/log/auth.log
backend = systemd
EOF

sudo systemctl restart fail2ban.service
sudo systemctl enable fail2ban.service
sudo systemctl status fail2ban.service
