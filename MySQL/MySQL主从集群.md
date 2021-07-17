MySQL设置复制主从服务器

## 版本号[¶](https://mariadb.com/kb/en/setting-up-replication/#versions)

一般来说，跨不同版本的 MariaDB 进行复制时，最好是 master 的版本比 slave 的版本旧。MariaDB 版本通常向后兼容，当然旧版本并不总是向前兼容。另请参见 [从MySQL Master复制到MariaDB Slave](https://mariadb.com/kb/en/setting-up-replication/#replicating-from-mysql-master-to-mariadb-slave)。

## 配置主站

-   如果尚未启用，请启用二进制日志记录。有关详细信息，请参阅[激活二进制日志](https://mariadb.com/kb/en/activating-the-binary-log/)和[二进制日志格式](https://mariadb.com/kb/en/binary-log-formats/)。

-   给主服务器一个唯一的[server_id](https://mariadb.com/kb/en/server-system-variables/#server_id)。所有从站也必须被赋予一个 server_id。这可以是 1 到 2 32 -1 之间的数字，并且对于复制组中的每个服务器必须是唯一的。

-   使用[--log-basename](https://mariadb.com/kb/en/mysqld-options-full-list/#-log-basename)为您的复制日志指定一个唯一名称。如果未指定此项，则将使用您的主机名，并且如果主机名发生更改，则会出现问题。

-   从服务器需要获得连接权限并开始从服务器复制。通常这是通过创建一个专用的从属用户并授予该用户仅复制权限（REPLICATION SLAVE 权限）来完成的。

### 为 MariaDB 启用复制的示例

将以下内容添加到[my.cnf](https://mariadb.com/kb/en/configuring-mariadb-with-mycnf/)文件中并重新启动数据库。

```
[mariadb]
log-bin
server_id=1
log-basename=master1
binlog-format=mixed
```

服务器 ID 是网络中每个 MariaDB/MySQL 服务器的唯一编号。 [binlog-format](https://mariadb.com/kb/en/binary-log-formats/)指定如何记录您的语句。这主要影响Master 和 Slaves 之间发送的[二进制日志](https://mariadb.com/kb/en/binary-log/)的大小。

然后用[`mysql`](https://mariadb.com/kb/en/mysql-command-line-client/)命令行客户端执行以下SQL ：

```
CREATE USER 'replication_user'@'%' IDENTIFIED BY 'bigs3cret';
GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'%';
```

### 为 MySQL 启用复制的示例

如果您想启用从 MySQL 到 MariaDB 的复制，您可以按照与 MariaDB 服务器之间几乎相同的方式进行。主要区别在于 MySQL 不支持`log-basename`.

# 获取master's 的binlogo



现在，您需要在查看二进制日志位置时防止对数据进行任何更改。您将使用它来告诉从服务器确切从哪个位置开始复制。

-   在 master 上，通过运行刷新并锁定所有表`FLUSH TABLES WITH READ LOCK`。保持此会话运行 - 退出它将释放锁定。
-   通过运行获取二进制日志中的当前位置`SHOW MASTER STATUS`：

```
UNLOCK TABLES;
```



## 启动奴隶

-   导入数据后，您就可以开始复制了。首先运行[CHANGE MASTER TO](https://mariadb.com/kb/en/change-master-to/)，确保*MASTER_LOG_FILE*与文件匹配，并且*MASTER_LOG_POS*与较早的 SHOW MASTER STATUS 返回的位置匹配。例如：

```
CHANGE  MASTER  TO 
  MASTER_HOST = 'master.domain.com' ，
  MASTER_USER = 'replication_user' ，
  MASTER_PASSWORD = 'bigs3cret' ，
  MASTER_PORT = 3306 ，
  MASTER_LOG_FILE = 'master1-bin.000096' ，
  MASTER_LOG_POS = 568 ，
  MASTER_CONNECT_RETRY = 10 ;
```

如果您正在针对从一开始就配置为复制的新主服务器启动从服务器，那么您不必指定`MASTER_LOG_FILE`和`MASTER_LOG_POS`。

```
START SLAVE;
```

```
SHOW SLAVE STATUS \G
```

-   If replication is working correctly, both the values of `Slave_IO_Running` and `Slave_SQL_Running` should be `Yes`:

```
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
```



更新日期 2021-6-15 注意文档更新时间



并发控制 ，当用户正在查询某条记录的时候刚好有另一个用户正在修改这条数据时候如何处理（exclesive lock 排他锁），当用户正在查询的时候刚好另一个用户正好删除了这条数据如何来处理（shared lock 共享锁）；



锁粒度 获得锁，检查锁状态，解除锁 都会带来性能消耗。所以锁定的范围（锁粒度）越小带来的性能损耗越小。例：表锁,行锁.

为了深刻理解（锁粒度）我们来举个厕所的例子：

厕所坑位为数据库中的数据数据，各种门为数据库中的锁，锁分别为公共厕所大门，男女厕所房间门，坑位门。 这时候我们的门卫（DBA）收到通知因为某某个公共厕所为了抢坑位打架了，让我们的门卫想办法杜绝这种情况发生。

锁有优先级，因为锁队列就是会排队的所以有插队的情况，写锁优先。



事务必须经过ACID测试

原子性（atomicity） 事务中所有的SQL合并起来为一个单元，不存在某些语句执行成功某些执行不成功。

一致性（consistency）事务中所有的SQL的状态总是一致性的，从一个一致性的状态转换到另外一个一致性状态。（原子性与一致性是否重复？

隔离性（ioslation）事务未执行成功对另一个事务通常来说是不可见的。

持久性（durability）事务执行完成后所有的修改都保存在服务器上面。



隔离级别

​	未提交读

​	提交读

​	可重复读

​	可串行化



死锁 两个以上的事务在同一资源上的相互占用，并请求锁定对面已经占用的资源引起的。当多个事务以不同的顺序锁定资源的时候可能会发生死锁。



MVCC



show table status 怎么用？



innodb