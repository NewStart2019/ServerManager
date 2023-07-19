#!/bin/sh

start_time=$(date +%s) # 获取当前时间戳（秒）
git --version
if [ "$?" -ne 127 ]; then
  echo "已经安装过git"
  exit 0
fi

sudo yum install -y git

git --version
end_time=$(date +%s)                # 获取当前时间戳（秒）
duration=$((end_time - start_time)) # 计算脚本执行时间（秒）
echo "安装成功,脚本执行时间：${duration} 秒"