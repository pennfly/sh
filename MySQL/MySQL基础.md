truncate table 清空表




```
SELECT * FROM smart_device_exception
INTO OUTFILE './smart_device_exception2.csv' 
FIELDS ENCLOSED BY '"' 
TERMINATED BY ',' 
LINES TERMINATED BY '\r\n';


SELECT * INTO OUTFILE '/tmp/smart_device_exception.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' FROM smart_device_exception;
```

```
# 导出
mysqldump boyu  -h 127.0.0.1 -u root -p123456 --tables smart_device_exception > /tmp/smart_device_exception.sql
# 导入
mysql> source /tmp/smart_device_exception.sql

-t 仅数据 
-d 仅结构


SELECT * INTO OUTFILE '/tmp/smart_device_exception.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' FROM smart_device_exception;



```



导出数据异常表

mysqldump vankeyi_debug  -h 127.0.0.1 -u root -p123456 --tables smart_device_exception > /tmp/smart_device_exception.sql

SELECT * INTO OUTFILE '/tmp/smart_device_exception.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' FROM smart_device_exception;
