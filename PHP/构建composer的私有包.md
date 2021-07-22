>   需求： 因为多个项目对接相同的支付平台，同时又需要适应很多的项目特性。所以决定对对支付部分进行解耦拆分，多个项目可以使用功能的代码库。支付代码库由专人负责维护。同时需要进行严格的开发和权限管理，避免造成代码外泄露。

进行评估发现composer的VCS管理 结合gitlab的控制符合公司的需求目标
下面进行简单测试整个流程的通畅

## 创建composer包
**创建composer包的方式**

-   手动创建`composer.json`文件

-   使用命令  `composer init`

**注意创建时候选择的类型**

```bash
# https://getcomposer.org/doc/04-schema.md#type
"type": "library",
```

**对代码进行发布到Git的私有仓库**

**示例**

链接： [我创建的私有仓库 Gitlab ](https://gitlab.com/penndev/version)

Branch： master


## 配置使用私有包

 **引用composer官方的包一般在项目下直接运行**

```shell
$ composer require monolog/monolog
```

**引用私有包**

在老项目中的composer.json中手动添加

```json
{
    "name": "penn/local",
    "description": "study the composer",
    "type": "project",
    "require": {
        "penn/version":"1.0.0"
    },
    "repositories": [
        {
            "type": "git",
            "url": "git@gitlab.com:penndev/version.git"
        }
    ]
}
```

运行`composer install`后发现`vendor\penn\version` 中代码已经更新到本地了。

目前已经初步完成了目标。

**包名问题**

`penn/version` 包名实际对应 [私有包](https://gitlab.com/penndev/version/-/blob/master/composer.json) 中的名称

```json
{
	"name": "penn/version",
	...
}
```

**版本问题**

**branch** 

-   `dev-master` 版本实际对应的Git Branch `master`

-   `1.0.0.x-dev` 版本对应的Git Branch `1.0.0`

**tag**

-   `1.0.0` 版本对应Git Tag `1.0.0`

-   `v1.0.0` 版本对应Git Tag `1.0.0`



## 实际运行使用

```php
<?php
require "vendor/autoload.php";
use Penn\Version\Main;
new Main();
```

