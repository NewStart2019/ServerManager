#node: /lib64/libm.so.6: version `GLIBC_2.27' not found (required by node)
#node: /lib64/libc.so.6: version `GLIBC_2.25' not found (required by node)
#node: /lib64/libc.so.6: version `GLIBC_2.28' not found (required by node)
#node: /lib64/libstdc++.so.6: version `CXXABI_1.3.9' not found (required by node)
#node: /lib64/libstdc++.so.6: version `GLIBCXX_3.4.20' not found (required by node)
# nvm v18开始 最新版本的需要GLIBC_2.27支持，目前系统没有那么高的版本。 libstdc++

if [ -e "${NVM_DIR}" ]; then
  echo -e "\e[31mNVM isn't already installed.\e[0m"
  exit 1
fi

#################### 更新glibc 需要bison
bison --version
if [ "$?" -ne 127 ]; then
  echo -e "\e[31m已经安装过bison\e[0m"
else
  sudo yum install bison
fi

#################### 下载glibc 需要 make4
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

####################  检查 gcc 的版本号 是否是8.3
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

# 安装 glibc
glibc_version=$(ldd --version | grep "2.28")
if [ -z "$glibc_version" ]; then
  echo -e "\e[31mGlibc-2.28 is not installed.Installing glibc\e[0m"
  cd || exit
  wget http://ftp.gnu.org/gnu/glibc/glibc-2.28.tar.gz
  tar xf glibc-2.28.tar.gz
  cd glibc-2.28/ && mkdir build && cd build || exit
  ../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin
  make && make install
  ldd --version
  cd || exit
  rm -rf glibc-2.28.tar.gz glibc-2.28
fi

# 升级libstdc++
# strings查看有没有GLIBCXX_3.4.20
libstdc_version=$(strings /usr/lib64/libstdc++.so.6 | grep GLIBCXX_3.4.20)
if [ -z "$libstdc_version" ]; then
  sudo wget http://www.vuln.cn/wp-content/uploads/2019/08/libstdc.so_.6.0.26.zip
  unzip libstdc.so_.6.0.26.zip
  cp libstdc++.so.6.0.26 /lib64/
  cd /lib64

  # 把原来的命令做备份
  cp libstdc++.so.6 libstdc++.so.6.bak
  rm -f libstdc++.so.6
  # 重新链接
  ln -s libstdc++.so.6.0.26 libstdc++.so.6
  # 移除多余的文件
  rm -rf libstdc.so_.6.0.26.zip libstdc++.so.6.0.26
fi
