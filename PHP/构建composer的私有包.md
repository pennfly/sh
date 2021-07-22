>   需求： 因为多个项目对接相同的支付平台，同时又需要适应很多的项目特性。所以决定对对支付部分进行解耦拆分，同时需要进行严格的开发权限管理。进行评估发现composer的VCS管理结合gitlab的控制符合公司的需求目标。

## 首先创建新的composer包

使用composer 命令行构建`composer init`

```json
{
    "name": "penn/version",
    "description": "echo php version",
    "type": "library",
    "autoload": {
        "psr-4": {
            "Penn\\Version\\": "src/"
        }
    },
    "authors": [
        {
            "name": "penn",
            "email": "pennilessfor@gmail.com"
        }
    ],
    "require": {}
}
```

然后将 version 上传到 gitlab仓库



## 在需要依赖的项目中增加上一步创建的包

在老项目中的composer.json中增加

```json
"require": {
	"penn/version":"^1.0.0"
}
```

然后运行

```shell
$ composer install
```

