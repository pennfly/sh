# mariadb 索引

## 做些准备

```
create table `student` (
	`id` int unsigned auto_increment primary key comment "id",
	`name` varchar(6) not null comment "名字",
	`age` tinyint unsigned not null comment "年纪",
	`nickname` varchar(3) comment "昵称",
	`school` varchar(20) not null comment "学校",
	`class` varchar(20) not null comment "班级",
	`score` decimal(4,2) unsigned comment "总成绩",
	`phone` char(11) not null comment "家庭电话",
	`address` text comment "家庭地址"
) engine = innoDB default charset = utf8mb4;
```



##### 插入大量测试数据

```
datafaker mysql mysql+mysqldb://root:123456@127.0.0.1:3306/study student 10000000 --meta meta.txt
```

##### datafaker的meta.txt

```
name||varchar(6)||学生名字
age||int||学生年龄[:age]
nickname||varchar(3)||学生小名[:enum(小青蛙,小王子,小苹果,小李子,小帅,小美,胖虎)]
school||varchar(20)||学校名字[:enum(清华中学,人和中心,北大附中,广东中学,新华中学,第一职中)]
class||varchar(20)||班级名称[:enum(七二,七一,六二,六一)]
score||decimal(4,2)||成绩[:decimal(4,2,1)]
phone||bigint||电话号码[:phone_number]
address||text||家庭地址[:address]
```



## [索引的主要类型](https://mariadb.com/kb/en/getting-started-with-indexes/)

### 主键 Primary key 

-   ​	主键索引的列值要求是唯一的，并且不能为空。

-   ​	一个`primary key`只能识别一条记录，并且每个记录都必须有`primary key`

-   ​	每个`table` 只能有一个`primary key`


​	number搭配 `AUTO_INCREMENT` 为新行生成 `primary key`

##### 创建语法

```
PRIMARY KEY(ID) #创建表时候添加
ALTER TABLE table_name ADD PRIMARY KEY(ID); #已经存在的表追加
```

##### 表引擎如果是`InnoDB` 

​		所有索引都是主键的节点，所以要保证主键尽可能的小。

​		如果`primary key`不存在或者没有 `unique indexes` ，`InnoDB`将创建一个6字节的`clustered index` ，该索引对于用户是不可见的。

##### 查找库中所有没有主键的表

```
SELECT t.TABLE_SCHEMA, t.TABLE_NAME
FROM information_schema.TABLES AS t
LEFT JOIN information_schema.KEY_COLUMN_USAGE AS c 
ON t.TABLE_SCHEMA = c.CONSTRAINT_SCHEMA
   AND t.TABLE_NAME = c.TABLE_NAME
   AND c.CONSTRAINT_NAME = 'PRIMARY'
WHERE t.TABLE_SCHEMA != 'information_schema'
   AND t.TABLE_SCHEMA != 'performance_schema'
   AND t.TABLE_SCHEMA != 'mysql'
   AND c.CONSTRAINT_NAME IS NULL;
```

### 唯一索引 Unique index

​	唯一索引列值必须是唯一的值。但可以为`NULL`，因为全`NULL`值不被记录在索引。

​	一个表可以有多个 `unique index` 存在。

​	唯一索引可以组合列使用 

​	最左原则

##### 创建语法

```
UNIQUE KEY (`index_item`) #创建表时候添加
ALTER TABLE table_name ADD UNIQUE `index_item`(`index_item`);#已经存在的表追加
CREATE UNIQUE INDEX index_item ON table_name(index_item);#已经存在的表追加
```

##### 联合唯一索引

```
CREATE TABLE t1 (a INT NOT NULL, b INT, UNIQUE (a,b));
INSERT INTO t1 values (1,1), (2,2), (2,1),(3,NULL), (3, NULL);
SELECT * FROM t1;
+---+------+
| a | b    |
+---+------+
| 1 |    1 |
| 2 |    1 |
| 2 |    2 |
| 3 | NULL |
| 3 | NULL |
+---+------+
#这样只验证a + b的唯一性。不单独区分a 或者b;
#UNIQUE约束会忽略NULL值，sql中null不等于任何东西包括null本身。所以可以同时存在(3, NULL);
```

### 普通索引 Plain Index

​	普通索引没有唯一约束，其他特性与唯一索引一样。

##### 创建语法

```
UNIQUE KEY (`index_item`) #创建表时候添加
ALTER TABLE table_name ADD INDEX `index_item`(`index_item`);#已经存在的表追加
CREATE INDEX index_item ON table_name(index_item);#已经存在的表追加
```

### 全文索引 full-text index

​	全文索引比普通索引配合like%快N个数量级，但是对中文支持不是很好。 

​	全文索引因为中文没有空格隔断，所以对中文支持很差。 必须开头到空格全部输入才能匹配到。

​	对于大型数据集，将数据加载到没有FULLTEXT索引的表中，然后再创建索引比将数据加载到具有现有FULLTEXT索引的表中要快得多。

​	只能用于 `char` `varchar` `text` 类型的列中

​	分区表不能包含全文索引。

```sql
FULLTEXT KEY (`index_item`) #创建表时候添加
ALTER TABLE table_name ADD FULLTEXT INDEX `index_item`(`index_item`);#已经存在的表追加
CREATE FULLTEXT INDEX index_item ON table_name(index_name);#已经存在的表追加

-查询
# address: 湖北省 林县兴山刘街B座 781285
SELECT * FROM student WHERE MATCH(address) AGAINST('林县兴山刘街B座');
# 以上在实例 可以使用[湖北省][林县兴山刘街B座][781285]这样的三个索引条件搜索到结果，如果使用[湖北]则索引不到，因为fulltext把[湖北省]三个中文字符看作的是一个整体。
```

## 什么是最左原则

最左原则适用联合索引

建立索引的顺序很重要，要结合业务去处理顺序。

与查询时候where的先后顺序无关。

例子：首先给表`student` 增加联合索引 `ALTER TABLE student ADD INDEX (name,age,phone);`

```
#本次使用name 使用了name联合索引
MariaDB root@localhost:study> explain select * from student where name = 'Penn'
+----+-------------+---------+------+---------------+------+---------+-------+------+-----------------------+
| id | select_type | table   | type | possible_keys | key  | key_len | ref   | rows | Extra                 |
+----+-------------+---------+------+---------------+------+---------+-------+------+-----------------------+
| 1  | SIMPLE      | student | ref  | name          | name | 26      | const | 4    | Using index condition |
+----+-------------+---------+------+---------------+------+---------+-------+------+-----------------------+
#使用了 name age 使用了name,age的索引
MariaDB root@localhost:study> explain select * from student where name = 'Penn' and age = 25
+----+-------------+---------+------+---------------+------+---------+-------------+------+-----------------------+
| id | select_type | table   | type | possible_keys | key  | key_len | ref         | rows | Extra                 |
+----+-------------+---------+------+---------------+------+---------+-------------+------+-----------------------+
| 1  | SIMPLE      | student | ref  | name          | name | 27      | const,const | 1    | Using index condition |
+----+-------------+---------+------+---------------+------+---------+-------------+------+-----------------------+
#使用了 name age phone 使用了全部的联合索引
MariaDB root@localhost:study> explain select * from student where name = 'Penn' and age = 25 and phone = '13333333333'
+----+-------------+---------+------+---------------+------+---------+-------------------+------+-----------------------+
| id | select_type | table   | type | possible_keys | key  | key_len | ref               | rows | Extra                 |
+----+-------------+---------+------+---------------+------+---------+-------------------+------+-----------------------+
| 1  | SIMPLE      | student | ref  | name          | name | 71      | const,const,const | 1    | Using index condition |
+----+-------------+---------+------+---------------+------+---------+-------------------+------+-----------------------+
# 这里使用 age phone 所有联合索引失效。
MariaDB root@localhost:study> explain select * from student where age = 25 and phone = '13333333333'
+----+-------------+---------+------+---------------+--------+---------+--------+----------+-------------+
| id | select_type | table   | type | possible_keys | key    | key_len | ref    | rows     | Extra       |
+----+-------------+---------+------+---------------+--------+---------+--------+----------+-------------+
| 1  | SIMPLE      | student | ALL  | <null>        | <null> | <null>  | <null> | 19797574 | Using where |
+----+-------------+---------+------+---------------+--------+---------+--------+----------+-------------+
# 这里使用 name phone 只有name的联合索引生效。
MariaDB root@localhost:study> explain select * from student where name = 'Penn' and phone = '13333333333'
+----+-------------+---------+------+---------------+------+---------+-------+------+-----------------------+
| id | select_type | table   | type | possible_keys | key  | key_len | ref   | rows | Extra                 |
+----+-------------+---------+------+---------------+------+---------+-------+------+-----------------------+
| 1  | SIMPLE      | student | ref  | name          | name | 26      | const | 4    | Using index condition |
+----+-------------+---------+------+---------------+------+---------+-------+------+-----------------------+
```



## 哪些情况会导致索引失效

like查询是以%开头

字符串类型的列没用 引号

使用`or`关键字

使用了 `null` 关键字

没有使用最左原则

对索引列进行计算和函数 != ,< > 等。

orderby group by 等使用违反了最左原则。





## Explain分析SQL

```
MariaDB root@localhost:study> explain select * from student where id = 1
+----+-------------+---------+-------+---------------+---------+---------+-------+------+-------+
| id | select_type | table   | type  | possible_keys | key     | key_len | ref   | rows | Extra |
+----+-------------+---------+-------+---------------+---------+---------+-------+------+-------+
| 1  | SIMPLE      | student | const | PRIMARY       | PRIMARY | 4       | const | 1    |       |
+----+-------------+---------+-------+---------------+---------+---------+-------+------+-------+
```

explain 中的字段与解释

id： 执行顺序从小打到递增，最先执行id最大的。

select_type:  查询类型

table: 用到的表名

type:  访问类型（重点。）

possible_keys： 能使用的索引

key:  实际使用的索引

key_len:   查询中使用的索引的长度 

ref: 连接匹配的条件

rows：表示MySQL根据表统计信息及索引选用情况，估算的找到所需的记录所需要读取的行数

Extra： mysql解决查询的详细信息

## 索引的数据结构与优化

对树的理解， B TREE  B+TREE 下次总结。
