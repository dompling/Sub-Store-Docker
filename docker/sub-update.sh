#!/bin/sh

gitPath="/git"
rootPath="/Sub-Store"
backend="$rootPath/backend"
web="$rootPath/Front"

echo -e "======================== 1. 启动nginx ========================\n"
echo -e "生成 nginx 配置文件\n"
envsubst '${ALLOW_IP}' < /etc/nginx/conf.d/front.template > /etc/nginx/conf.d/front.conf
nginx -s reload 2>/dev/null || nginx -c /etc/nginx/nginx.conf
echo -e "==============================================================\n"

echo -e "======================== 2、更 新 仓 库 ========================\n"

cd "$gitPath/Front" && git reset --hard && git pull 
sleep 2s
cd "$gitPath/Sub-Store" && git reset --hard && git pull
sleep 2s
cd "$gitPath/Docker" && git reset --hard && git pull

sleep 2s
ln -sf "$gitPath/Docker/docker/sub-update.sh" /usr/bin/sub_update && chmod +x /usr/bin/sub_update

echo -e "==============================================================\n"

echo -e "======================== 3、重启后端接口 ========================\n"

cp -r "$gitPath/Sub-Store/backend" "$rootPath"
pm2 restart sub-store

echo -e "==============================================================\n"

echo -e "======================== 4、重启 UI 界面 ========================\n"

cp -r "$gitPath/Front" "$rootPath"
echo -e "删除自带后端地址，追加配置环境变量配置的后端地址\n"

sed -i "/VITE_API_URL|ENV/d" "$web/.env.production"
echo "ENV = 'production'\nVITE_API_URL = '${DOMAIN}'" >>"$web/.env.production"

cd "$web"
echo -e "执行编译前端静态资源\n"    
pnpm run build
echo -e "结束编译，UI 界面已生成\n"

pm2 log sub-store
exec "$@"