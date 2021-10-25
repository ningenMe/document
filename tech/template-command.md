# 業務中よく打つけど忘れがちコマンド

### レコード数確認するコマンド
```
select table_name, table_rows from information_schema.TABLES;
```
### localのcurrent branch以外削除するコマンド
```
git branch | xargs git branch -D
```

### localのdocker雑に落とすコマンド
```
docker rm `docker ps -a`
docker volume rm `docker volume ls -q`
```

