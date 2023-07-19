#!/bin/sh

start_time=$(date +%s) # 获取当前时间戳（秒）
nginx -v
if [ "$?" -ne 127 ]; then
  echo "已经安装过nginx"
  exit 0
fi

sudo yum install -y epel-release
sudo yum update
sudo yum install -y nginx
sudo nginx
sudo systemctl status nginx

# 检查防火墙状态
firewall_status=$(systemctl is-active firewalld)
if [ "$firewall_status" != "active" ]; then
  echo "防火墙未开启，无需进行端口检查和开放。"
  exit 0
fi

# 检查80端口是否已打开
if ! firewall-cmd --list-ports | grep -q "80/tcp"; then
  echo "80端口未打开，正在开放80端口..."
  # 开放防火墙
  firewall-cmd --zone=public --add-port=80/tcp --permanent
  firewall-cmd --reload
  sudo firewall-cmd --list-ports
  echo "已成功开放80端口。"
else
  echo "80端口已经打开，无需开放。"
fi

end_time=$(date +%s)                # 获取当前时间戳（秒）
duration=$((end_time - start_time)) # 计算脚本执行时间（秒）
echo "安装nginx成功,脚本执行时间：${duration} 秒"
