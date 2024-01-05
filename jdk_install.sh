#!/bin/sh

###########################
# 文件说明
# 1、本文件只支持安装的版本 1.8、11（yum安装），17，20（手动下载安装）.
# 2、检测已经安装过java之后不再安装
# 3、exit 0 表示执行成功，127，表示命令没有找到
###########################

start_time=$(date +%s) # 获取当前时间戳（秒）
JAVE_VERSION=$1

java=$(command -v objdump)
if [ -z "$java" ]; then
  echo "已经安装过jdk"
  exit 0
fi

curl --version >> /dev/null
if [ "$?" = 127 ]; then
  yum install -y curl
fi

# jdk17 或者 20 需要手动下载安装
if [ "$JAVE_VERSION" = 17 ] || [ "$JAVE_VERSION" = 20 ]; then
  # 获取系统架构,安装指定架构版本的jdk
  arch="$(objdump="$(command -v objdump)" && objdump --file-headers "$objdump" | awk -F '[:,]+[[:space:]]+' '$1 == "architecture" { print $2 }')"
  if [ -z "$arch" ]; then
      arch="$(objdump="$(command -v objdump)" && objdump --file-headers "$objdump" | awk -F '[：，]+' '$1 == "体系结构" { print $2 }')"
  fi
  case "$arch" in 'i386:x86-64')
    JAVA_URL=http://172.16.0.97:84/jdk/Linux/jdk-${JAVE_VERSION}_linux-x64_bin.rpm
    ;;
  'aarch64')
    JAVA_URL=http://172.16.0.97:84/jdk/Linux/jdk-${JAVE_VERSION}_linux-aarch64_bin.rpm
    ;;
  *)
    echo >&2 "error: unsupported architecture: '$arch'"
    exit 1
    ;;
  esac

  PACKAGE_NAME="openjdk.rpm"
  echo $JAVA_URL
  curl -fL -o $PACKAGE_NAME "$JAVA_URL"
  chmod +x $PACKAGE_NAME
  rpm -ivh $PACKAGE_NAME

  rm -rf $PACKAGE_NAME
  java -version
  end_time=$(date +%s)                # 获取当前时间戳（秒）
  duration=$((end_time - start_time)) # 计算脚本执行时间（秒）
  echo "安装成功,脚本执行时间：${duration} 秒"
  exit 0
fi

# 安装jdk1.8 java-11-openjdk.x86_64
java_package_name="java-1.8.0-openjdk.x86_64"
if [ "$JAVE_VERSION" = 11 ]; then
  java_package_name="java-11-openjdk.x86_64"
fi
yum install -y $java_package_name

java -version
end_time=$(date +%s)                # 获取当前时间戳（秒）
duration=$((end_time - start_time)) # 计算脚本执行时间（秒）
echo "安装成功,脚本执行时间：${duration} 秒"

# 卸载yum安装的所有java： rpm -e --nodeps $(rpm -qa | grep java)
# 手动安装则需要自己，手动卸载
