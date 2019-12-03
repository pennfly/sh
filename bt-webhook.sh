#根据宝塔webhook传入的参数自动统配所有项目。
if [ ! -n "$1" ];
then 
          echo "param参数错误"
          echo "End"
          exit
fi
#替换为实际的站点地址
webPath="/www/wwwroot/$1"
#替换为自己的git目录
gitUrl="git@github.com:user/$1.git"
echo "Web站点路径：$webPath Git地址: $gitUrl"

#判断项目路径是否存在
if [ ! -d "$webPath" ]; then
        mkdir -p $webPath
fi

cd $webPath
#判断是否存在git目录
if [ ! -d ".git" ]; then
        echo "在该目录下克隆 git"
        git clone $gitUrl gittemp
        mv gittemp/.git .
        rm -rf gittemp
fi
git reset --hard origin/master
git pull origin master
echo "做些事情吧  (^-^)"
chown -R www:www $webPath
echo "更新完成 - Finish"
exit
