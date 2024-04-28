#!/bin/bash

# 安装位置
INSTALL_DIR="/usr/local/frp"

# 下载 frp 最新版本
FRP_VERSION="0.52.3"
FRP_DOWNLOAD_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"
echo "Downloading frp..."
wget -q --show-progress "$FRP_DOWNLOAD_URL" -O frp.tar.gz

# 解压并移动到指定位置
echo "Installing frp..."
tar -zxvf frp.tar.gz
mkdir -p "$INSTALL_DIR"
mv frp_${FRP_VERSION}_linux_amd64/* "$INSTALL_DIR"
rm -rf frp_${FRP_VERSION}_linux_amd64
rm -f frp.tar.gz

# 询问 token
read -p "Enter your frps token: " FRPS_TOKEN

# 询问后台用户名和密码
read -p "Enter dashboard username: " DASHBOARD_USER
read -p "Enter dashboard password: " DASHBOARD_PASSWD

# 生成配置文件
cat > "$INSTALL_DIR/frps.toml" <<EOF
[common]
bind_addr = 0.0.0.0
bind_port = 7000
token = $FRPS_TOKEN
dashboard_addr = 0.0.0.0
dashboard_port = 7500
dashboard_user = $DASHBOARD_USER
dashboard_pwd = $DASHBOARD_PASSWD
EOF

# 设置开机自启动
cat > /etc/systemd/system/frps.service <<EOF
[Unit]
Description=frp server
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/frps -c $INSTALL_DIR/frps.ini
Restart=on-failure
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

# 启动 frps 服务
systemctl daemon-reload
systemctl enable frps
systemctl start frps

echo "frps installation completed!"
