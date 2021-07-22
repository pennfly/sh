MySQL复制是让一台服务器的数据与其他服务器保持同步。



MySQL支持两种复制方式 

基于行的复制

基于语句的复制

都是通过主库日志上记录二进制日志，在备库重放日志实现的。可能会有较长时间的延迟。



老主新从。

什么是TPS

什么是RAID

SNA NAS

内存交换



## 配置MySQL复制的流程

1.  创建复制账号

2.  配置主库和备库

3.  设置主库

    ```
    # my.cnf
    log_bin = mysql-bin
    server_id = 10
    
    # 查看binlog状态
    show master sstatus;
    ```

4.  设置从库

    ```
    # my.cnf
    log_bin = mysql-bin
    server_id = 10
    relay_log = /var/lib/mysql/mysql-relay-bin
    log_slave_updates = 1
    read_only = 1
    
    # 启动从库复制
    change master to master_host="localhost",
    master_user="user",
    master_password="123456",
    master_log_file="==",
    master_log_pos=0;
    # 检查配置状态。
    show slave status\G;
    # 启动从库
    start slave；
    ```

    



sho processlist;







## 配置全新两台一主一从

[复制官方文档](https://mariadb.com/kb/en/replication-cluster-multi-master/)

利用dockers来处理 

```console
docker run --name db-master -e MYSQL_ROOT_PASSWORD=123456 -d mariadb:latest
```

```
docker run --name db-slave -e MYSQL_ROOT_PASSWORD=123456 -d mariadb:latest
```



