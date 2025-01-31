#!/bin/bash
set -e

dir_shell=/ql/shell
. $dir_shell/share.sh
link_shell
echo -e "======================1. 检测配置文件========================\n"
fix_config
cp -fv $dir_root/docker/front.conf /etc/nginx/conf.d/front.conf
echo

echo -e "======================2. 更新源代码========================\n"
ql update
echo

echo -e "======================3. 启动nginx========================\n"
nginx -s reload 2>/dev/null || nginx -c /etc/nginx/nginx.conf
echo -e "nginx启动成功...\n"

echo -e "======================4. 启动控制面板========================\n"
cd $dir_root
if [[ $(pm2 info panel) ]]; then
  pm2 reload panel
else
  pm2 start $dir_root/build/app.js -n panel
fi
echo -e "控制面板启动成功...\n"

echo -e "======================5. 启动定时任务========================\n"
cd $dir_root
if [[ $(pm2 info schedule) ]]; then
  pm2 reload schedule
else
  pm2 start $dir_root/build/schedule.js -n schedule
fi
echo -e "定时任务启动成功...\n"

if [[ $AutoStartBot == true ]]; then
  echo -e "======================6. 启动bot========================\n"
  cd $dir_root
  ql bot
  echo -e "bot启动成功...\n"
fi

echo -e "############################################################\n"
echo -e "容器启动成功..."
echo -e "\n请先访问5700端口，登录成功面板之后再执行添加定时任务..."
echo -e "############################################################\n"

crond -f

exec "$@"
