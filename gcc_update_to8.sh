#!/usr/bin/env bash

# yum 方式安装
gcc_upgrade(){
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
}

# 下载包编译安装，安装成功后退出ssh重新连接查看版本
gcc_upgrade11(){
  gcc_version=$(gcc --version | grep -oP '(?<=gcc \(GCC\) )(\d+\.\d+.\d+)')
  # 检查是否为空（即 gcc 是否安装）
  if [ -z "$gcc_version" ] || [ "$gcc_version"  !=  "11.2.0" ]; then
    echo -e "\e[31m正在升级gcc到11.2.0\e[0m"
    wget http://172.16.0.97:84/gcc/gcc-11.2.0.tar.gz
#    wget http://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.gz
    # 腾讯软件源 https://mirrors.cloud.tencent.com/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.gz
    tar -zxvf gcc-11.2.0.tar.gz
    # 安装bzip2
    bzip2 -V
    if [ "$?" -ne 127 ]; then
      echo -e "\e[31m已经安装过bzip2\e[0m"
    else
      sudo yum -y install bzip2
    fi
    cd gcc-11.2.0
    ./contrib/download_prerequisites
    mkdir build && cd build/ || exit
    # 如果失败：sudo yum groupinstall "Development Tools" # 包括 gcc 和 g++
    ../configure --prefix=/usr/local --enable-checking=release --enable-languages=c,c++ --disable-multilib
    # --prefix=/usr/local 配置安装目录
    #–enable-languages表示你要让你的gcc支持那些语言，
    #–disable-multilib不生成编译为其他平台可执行代码的交叉编译器。
    #–disable-checking生成的编译器在编译过程中不做额外检查，
    #也可以使用*–enable-checking=xxx*来增加一些检查

    make && make install
    gcc -v
    cd || exit
    rm -rf gcc-11.2.0 gcc-11.2.0.tar.gz
  fi
}
