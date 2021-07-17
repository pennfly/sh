# PHP 开发笔记



## composer

-   安装composer镜像管理工具：`	composer global require slince/composer-registry-manager` 
-   更换composer镜像进行加速：`composer repo:ls`   `composer repo:use aliyun`

###### 自动加载

你可以在 `composer.json` 的 `autoload` 字段中增加自己的 autoloader。

```json
{
    "autoload": {
        "psr-4": {"Acme\\": "src/"}
    }
}
```

Composer 将注册一个 [PSR-4](http://www.php-fig.org/psr/psr-4/) autoloader 到 `Acme` 命名空间。

你可以定义一个从命名空间到目录的映射。此时 `src` 会在你项目的根目录，与 `vendor` 文件夹同级。例如 `src/Foo.php` 文件应该包含 `Acme\Foo` 类。

添加 `autoload` 字段后，你应该再次运行 `install` 命令来生成 `vendor/autoload.php` 文件。

```php
$loader = require 'vendor/autoload.php';
$loader->add('Acme\\Test\\', __DIR__);
```

除了 PSR-4 自动加载，classmap 也是支持的



repositories 仓库包处理



###### 平台软件包

Composer 将那些已经安装在系统上，但并不是由 Composer 安装的包视为一个虚拟的平台软件包。这包括PHP本身，PHP扩展和一些系统库。

-   `php` 表示用户的 PHP 版本要求，你可以对其做出限制。例如 `>=5.4.0`。如果需要64位版本的 PHP，你可以使用 `php-64bit` 进行限制。
-   `hhvm` 代表的是 HHVM（也就是 HipHop Virtual Machine） 运行环境的版本，并且允许你设置一个版本限制，例如，'>=2.3.3'。
-   `ext-<name>` 可以帮你指定需要的 PHP 扩展（包括核心扩展）。通常 PHP 拓展的版本可以是不一致的，将它们的版本约束为 `*` 是一个不错的主意。一个 PHP 扩展包的例子：包名可以写成 `ext-gd`。
-   `lib-<name>` 允许对 PHP 库的版本进行限制。
    以下是可供使用的名称：`curl`、`iconv`、`icu`、`libxml`、`openssl`、`pcre`、`uuid`、`xsl`。

你可以使用 `composer show --platform` 命令来获取可用的平台软件包的列表。



###### 安装 `install`

`install` 命令从当前目录读取 `composer.json` 文件，处理了依赖关系，并把其安装到 `vendor` 目录下。

```sh
php composer.phar install
```

如果当前目录下存在 `composer.lock` 文件，它会从此文件读取依赖版本，而不是根据 `composer.json` 文件去获取依赖。这确保了该库的每个使用者都能得到相同的依赖版本。

如果没有 `composer.lock` 文件，composer 将在处理完依赖关系后创建它。

-   **--optimize-autoloader (-o):** 转换 PSR-0/4 autoloading 到 classmap 可以获得更快的加载支持。特别是在生产环境下建议这么做，但由于运行需要一些时间，因此并没有作为默认值。





## laravel 开发流程

-       ```shell
    composer global require laravel/installer
    ```

-   `laravel new example-app`

-   

## Nginx 504

​	504 Gateway Time-out
