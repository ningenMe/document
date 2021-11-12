# locals

# init
- キーボード設定を修正
- Safariからchromeをダウンロードする
- https://brew.sh/index_ja から brew をインストール
- ~/.zshrcに下記を追加
```shell
typeset -U path PATH
path=(
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /usr/bin
  /usr/sbin
  /bin
  /sbin
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /Library/Apple/usr/bin
)
```
- Source treeから https://www.atlassian.com/ja/software/sourcetree をインストール
- https://github.com/ にアクセス
- source treeでssh keyを作成
- https://github.com/ningenMe/locals を ~/repos/にclone
- https://www.jetbrains.com/ でintellijをインストール

# app
- discordをインストール
- 画面共有に許可を入れる

# runtime
- 基本的にはasdfで入れる
## asdf
- http://asdf-vm.com/guide/getting-started.html#_1-install-dependencies を読んでセットアップしていく
```shell
brew install asdf
# パスを通す
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
# asdfが通るか確認
asdf plugin list all
# 依存関係を追加
brew install gpg gawk
```

## nodejs
```shell
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf list all nodejs
asdf install nodejs 17.0.0
asdf global nodejs 17.0.0
node --version
```

## java
- https://www.azul.com/downloads/?version=java-17-lts&os=macos&architecture=arm-64-bit&package=jdk からインストール(asdfでm1で動くやつがなかった)
- 下記コマンドで確認
```
ls /Library/Java/JavaVirtualMachines 
java --version
```

## go
```shell
asdf plugin add golang https://github.com/kennyp/asdf-golang.git
asdf list all golang
asdf install golang 1.17.3
asdf global golang 1.17.3
go --version
```

## c++
- asdfにないっぽいのでbrew
```shell
brew install gcc
g++ --version
```

## rust
```shell
asdf plugin add rust https://github.com/code-lever/asdf-rust.git
asdf list all rust
asdf install rust 1.56.1
asdf global rust 1.56.1
cargo --version
rustc --version
rustdoc --version
```

## python
```shell
python3 --version
```

## docker
- https://docs.docker.com/desktop/mac/apple-silicon/ からインストール
- パス通るの時間かかるかも？
```shell
docker --version
docker-compose --version
```

## terraform
```shell
asdf plugin add terraform https://github.com/Banno/asdf-hashicorp.git
asdf list all terraform
asdf install terraform 1.0.11
asdf global terraform 1.0.11
```

## awscli
- https://github.com/aws/aws-cli/blob/v2/CHANGELOG.rst でバージョン確認
```shell
cd ~
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
rm AWSCLIV2.pkg 
aws --version
```