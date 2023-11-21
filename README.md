# ServerManager

## 项目说明

* 用于服务器环境初始化
* 可以安装：jdk、nvm（yarn）、nginx、git、docker(docker-compose)
* 目前脚本只适用于centos（其他系统没测试是否兼容，后面有需求则会支持其他Linux系统）
* 安装nvm的时候需要自己手动指定 nvm_install.sh 69行的仓库地址 NVM_SOURCE_URL=http://xxxx/nvm.git。由于github不能访问的原因。本地仓库需要把标签v0.38.0上传

## 项目结构

```
├── README.md
├── .gitlab-ci.yml
├── docker_andcompose_install.sh
├── git_install.sh
├── jdk_install.sh
├── nvm_install.sh
├── nginx_install.sh
└── yarn_install.sh
```


## 下载

```

cd existing_repo
git remote add origin http://172.16.0.145:8929/tool/ServerManager.git
git branch -M master
git push -uf origin master

```
