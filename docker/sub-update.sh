#!/bin/sh

gitPath="/git"
rootPath="/Sub-Store"
backend="$rootPath/backend"
web="$rootPath/web"
nginx="$rootPath/nginx"


echo -e "======================== 1、更 新 仓 库 ========================\n"

cd "$gitPath" && git reset --hard && git pull 
sleep 2s
echo -e "==============================================================\n"

echo -e "======================== 2、重启后端接口 ========================\n"

cp -r /git/backend "$rootPath"
cd $backend
pm2 restart sub-store --source-map-support --time

echo -e "==============================================================\n"

echo -e "======================== 3、重启 UI 界面 ========================\n"

cp -r /git/web "$rootPath"
echo -e "删除自带后端地址，追加配置环境变量配置的后端地址\n"
sed -i "/BACKEND_BASE\|DEBUG\|DOMIAN/d" "$web/src/config.js"
echo "export const BACKEND_BASE = '${DOMAIN}';" >>"$web/src/config.js"
cd "$web"
echo -e "执行编译前端静态资源\n"    
npm run build
echo -e "结束编译，UI 界面已生成\n"

pm2 log sub-store
exec "$@"