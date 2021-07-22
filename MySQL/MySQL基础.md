truncate table 清空表




```
SELECT * FROM smart_device_exception
INTO OUTFILE '/tmp/smart_device_exception.csv' 
FIELDS ENCLOSED BY '"' 
TERMINATED BY ',' 
ESCAPED BY '"' 
LINES TERMINATED BY '\r\n';
```

```
mysqldump boyu  -h 127.0.0.1 -u root -p123456 --tables smart_device_exception > /tmp/smart_device_exception.sql
```

