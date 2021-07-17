Docker 使用手册

#### docker cp

容器到本地目录

```bash
$docker cp  主机名称:/来源目录  /目标目录
```

 本地到容器主机

```bash
$docker cp  /来源目录 主机名称:/目标目录
```

docker log

```
      --details        详细日志模式
  -f, --follow         实时跟踪输出
      --since string   自定义时间格式输出
  -n, --tail string    从末尾开始显示多少行
  -t, --timestamps     显示时间戳
      --until string   显示多久前的日志

```

```bash
$docker update
```

docker update --restart=always 

