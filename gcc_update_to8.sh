#!/usr/bin/env bash

# 检查 gcc 的版本号 是否是8.3
gcc_version=$(gcc --version | grep -oP '(?<=gcc \(GCC\) )(\d+\.\d+.\d+)')

# 检查是否为空（即 gcc 是否安装）
if [ -z "$gcc_version" ]; then
  echo -e "\e[31mGCC is not installed.\e[0m"
else
  echo "Installed GCC version: $gcc_version"
  # 检查是否是 4.x 版本
  if [[ "$gcc_version" == "4."* ]]; then
    echo "GCC version 4.x is already installed."
  else
    echo "Installing GCC version 4.x..."
    # 升级GCC(默认为4 升级为8)
    yum install -y centos-release-scl
    yum install -y devtoolset-8-gcc*
    mv /usr/bin/gcc /usr/bin/gcc-4.8.5
    ln -s /opt/rh/devtoolset-8/root/bin/gcc /usr/bin/gcc
    mv /usr/bin/g++ /usr/bin/g++-4.8.5
    ln -s /opt/rh/devtoolset-8/root/bin/g++ /usr/bin/g++
  fi
fi
