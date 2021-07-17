#根据宝塔webhook传入的参数自动统配所有项目。 后追加的参数为$(int) $1,$2...

echo "Hook action Time:" $(date +"%Y-%m-%d %H:%M:%S")

# 判断是否存在参数。
if [ ! -n "$1" ]; then 
          echo "param参数不存在..."
fi


dir ="/www/wwwroot/$1"
#判断项目路径是否存在
if [ ! -d "$dir" ]; then
        echo "Dir 目录不存在：$dir"
        echo "end..."
        exit
fi

echo "本次操作目录：$dir"
cd $webPath

git reset --hard origin/master
git pull origin master

echo "Hook finish Time:" $(date +"%Y-%m-%d %H:%M:%S")
echo
exit
