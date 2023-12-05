# 業務中よく打つけど忘れがちコマンド

### レコード数確認するコマンド
```
select table_schema, table_name, table_rows from information_schema.TABLES where not table_schema in ('information_schema', 'mysql', 'performance_schema', 'sys');
```
### localのcurrent branch以外削除するコマンド
```
git branch | grep -v "*" | xargs git branch -D
```

### localのdocker雑に落とすコマンド
```
docker container stop `docker container ls -qa`
docker container rm `docker container ls -qa`
docker volume rm `docker volume ls -q`
```

### pathを出力するコマンド
```
echo $PATH | sed 's/:/\'$'\n/g'
```

### localの<none>のimageを削除するコマンド
```shell
docker image rmi `docker image ls | grep none | awk '{print $3}' | xargs`
```