#!/usr/bin/env bash

make_version=$(make -v | grep -oP '(?<=GNU Make )(\d+\.\d+)')
# 检查是否为空（即 make 是否安装）
if [ -z "$make_version" ]; then
  echo -e "\e[31mMake is not installed.Installing make\e[0m"
  yum install make
  make -v
else
  echo -e "\e[31mInstalled make version: $make_version\e[0m"
  # 检查是否是 4.x 版本
  if [[ "$make_version" == "4."* ]]; then
    echo -e "\e[31mMake version 4.x is already installed.\e[0m"
  else
    echo -e "\e[31mInstalling make version 4.x...\e[0m"
    # 升级make 4.x 的命令
    cd || exit
    wget http://ftp.gnu.org/gnu/make/make-4.3.tar.gz
    tar -xzvf make-4.3.tar.gz && cd make-4.3/ || exit
    ./configure --prefix=/usr/local/make
    make && make install
    cd /usr/bin/ && mv make make.bak
    ln -sv /usr/local/make/bin/make /usr/bin/make
    cd || exit
    rm -rf make-4.3.tar.gz make-4.3
  fi
fi
