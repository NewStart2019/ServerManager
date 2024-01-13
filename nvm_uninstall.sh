#!/usr/bin/env bash

{
  rm -rf $NVM_DIR
  sed -i '/export NVM_DIR="$HOME\/.nvm"/d' $HOME/.bashrc
  sed -i '/[ -s "$NVM_DIR\/nvm.sh" ] && \. "$NVM_DIR\/nvm.sh"/d' $HOME/.bashrc
  sed -i '/[ -s "$NVM_DIR\/bash_completion" ] && \. "$NVM_DIR\/bash_completion"/d' $HOME/.bashrc
  source $HOME/.bashrc  # 或者 source ~/.zshrc，根据你的 shell 配置文件而定
}
