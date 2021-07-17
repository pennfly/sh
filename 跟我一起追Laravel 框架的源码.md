#  跟我一起追Laravel 框架的源码

laravel到底怎么读？ 首先看音标读法 `[lærəvel]` 不要读错了了哦。 

`Laravel Framework 8.41.0`

1.  `public/index.php`  

    -   定义脚本开始时间  `LARAVEL_START`
    -   判断是否在[维护](https://laravel.com/docs/8.x/configuration#maintenance-mode)模式中 。
    -   加载`composer autoload`

2.   `bootstrap/app.php`

    1.   `new Illuminate\Foundation\Application` 实例化 Application

    2.   在`vendor/composer/autoload_classmap.php`找到 `Illuminate\Foundation\Application` 的真实文件`vendor/laravel/framework/src/Illuminate/Foundation/Application.php`

    3.  看`Application`的 `__construct` 首先这个`Application` 就是顶顶大名的Laravel的容器。

        1.  首先容器的构造函数：`Application->_construct`

            ```php
            代码解释为： $app = 容器的实例
            #调用了setBasePath 方法
            $app->basePath = 项目的根目录
            #调用了instance 方法
            $app->abstractAliases 删除传入的参数
            $app->aliases 删除传入参数
            $app->instances 添加传入参数
            #调用了registerBaseBindings();
            
            ```
            
            ​    
            
        2.  ```php
            #容器的方法
            instance {
                $app->abstractAliases 删除传入的参数
                $app->aliases 删除传入参数
                $app->instances 添加传入参数
            }
            
            singleton-> {
                
            }
            
            ```
        
            
        
        3.  ![image-20210517141253575](C:\Users\Penn\AppData\Roaming\Typora\typora-user-images\image-20210517141253575.png)
        
        

![image-20210517141359729](C:\Users\Penn\AppData\Roaming\Typora\typora-user-images\image-20210517141359729.png)

![image-20210517141427037](C:\Users\Penn\AppData\Roaming\Typora\typora-user-images\image-20210517141427037.png)

![image-20210517141540037](C:\Users\Penn\AppData\Roaming\Typora\typora-user-images\image-20210517141540037.png)