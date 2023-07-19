#!/bin/sh

start_time=$(date +%s) # 获取当前时间戳（秒）
npm --version
if [ "$?" -ne 127 ]; then
  echo "已经安装过npm"
  exit 0
fi

curl -fsSL https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo yum install -y nodejs

# 下载安装脚本
curl -L https://npmjs.org/install.sh | sudo sh
# 查看版本
npm --version
# 安装 yarn
sudo npm install -g yarn
yarn --version
end_time=$(date +%s)                # 获取当前时间戳（秒）
duration=$((end_time - start_time)) # 计算脚本执行时间（秒）
echo "安装成功,脚本执行时间：${duration} 秒"