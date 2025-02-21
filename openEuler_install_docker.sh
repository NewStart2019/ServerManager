#!/bin/bash
# author：@运维有术
# Usage：自动安装 Docker 24.0.7
set -e

# 设置主机名，默认为 docker-node-1
hostname=${1:-"docker-node-1"}

# 设置 Docker 版本，默认为 24.0.7
docker_ver=${2:-"24.0.7"}

# 操作系统基础配置
function sys_init(){
  hostnamectl set-hostname ${hostname}
  echo "nameserver 114.114.114.114" > /etc/resolv.conf
  timedatectl set-timezone Asia/Shanghai
  # 安装并配置时间同步
  yum install chrony -y
  sed -i 's/^pool pool.*/pool cn.pool.ntp.org iburst/g' /etc/chrony.conf
  systemctl enable chronyd --now
  systemctl stop firewalld && systemctl disable firewalld
  sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
  setenforce 0
}

# 磁盘配置
function disk_init(){
  #  创建 PV
  pvcreate /dev/sdb
  # 创建 VG
  vgcreate data /dev/sdb
  #  创建 LV
  lvcreate -l 100%VG data -n lvdata
  #  格式化磁盘
  mkfs.xfs /dev/mapper/data-lvdata
  mkdir /data
  #  挂载磁盘
  mount /dev/mapper/data-lvdata /data/
  tail -1 /etc/mtab >> /etc/fstab
}

# 安装配置 Docker
function docker_install(){
  mkdir -p /data/docker
  curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
  sed -i 's#https://download.docker.com#https://mirrors.tuna.tsinghua.edu.cn/docker-ce#' /etc/yum.repos.d/docker-ce.repo
  sed -i 's#$releasever#7#g' /etc/yum.repos.d/docker-ce.repo
  yum install docker-ce-${docker_ver} docker-ce-cli-${docker_ver} docker-ce-rootless-extras-${docker_ver} containerd.io docker-buildx-plugin docker-compose-plugin -y
  file="/etc/docker/daemon.json"
  if [ ! -f "$file" ]; then
    echo '{
  "data-root": "/data/docker",
  "insecure-registries": ["172.16.0.197:8083","172.16.0.197:8929"],
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "http://172.16.0.197:8083/",
    "http://172.16.0.197:8929/"
  ],
  "log-driver":"json-file",
  "log-opts": {
    "max-size": "500m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "exec-opts": ["native.cgroupdriver=systemd"]
}' | sudo tee "$file" >/dev/null
    # 如果没有对应的  ~/.docker/config.json 文件直接创建目录和文件
    if [ ! -d "$HOME/.docker" ]; then
        mkdir -p "$HOME/.docker"
    fi
    if [ ! -f "$HOME/.docker/config.json" ]; then
      echo '{
    "auths": {
      "172.16.0.197:8083": {
        "auth": "YWRtaW46czlBR2R6RmFTTFh5UXJE"
      },
      "172.16.0.197:8929": {
        "auth": "emhhbnFoOmdscGF0LW9odWUzZERRQ1hlaXRqWXZZaEt2"
      }
    }
  }'  | sudo tee ~/.docker/config.json >/dev/null
    fi
    echo "File $file created and content written."
  else
    echo "File $file already exists."
  fi
  systemctl enable docker --now
}

function docker_check(){
  docker info
  docker run hello-world
}

sys_init
#disk_init
docker_install
docker_check