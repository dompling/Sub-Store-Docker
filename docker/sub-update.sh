#!/bin/sh

gitPath="/git"
rootPath="/Sub-Store"
backend="$rootPath/backend"
web="$rootPath/Front"

echo -e "======================== 1、更 新 仓 库 ========================\n"

    cd "$gitPath/Front" && git reset --hard && git pull 
    sleep 2s
    cd "$gitPath/Sub-Store" && git reset --hard && git pull
    sleep 2s
    cd "$gitPath/Docker" && git reset --hard && git pull
    sleep 2s
    ln -sf "$gitPath/Docker/docker/sub-update.sh" /usr/bin/sub_update && chmod +x /usr/bin/sub_update

echo -e "==============================================================\n"

echo -e "======================== 2、启动后端接口 ========================\n"

    cp -r "$gitPath/Sub-Store/backend" "$rootPath"
    cd "$backend" && pnpm install && pnpm build
    pm2 restart sub-store

echo -e "==============================================================\n"

echo -e "======================== 3、启动 Sub-Store 界面 ========================\n"
    cp -r "$gitPath/Front" "$rootPath"
    cd "$web" && pnpm install

    echo -e "删除自带后端地址，追加配置环境变量配置的后端地址\n"

    sed -i "/ENV/d" "$web/.env.production"
    echo "VITE_API_URL = '${DOMAIN}'" >>"$web/.env.production"

    cd "$web"
    echo -e "执行编译前端静态资源\n"    
    pnpm run build
    echo -e "结束编译，UI 界面已生成\n"

echo -e "==============================================================\n"


exit 0