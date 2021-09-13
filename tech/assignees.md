# githubでプルリクエストを作った人を自動でassigneesにする

## はじめに
こんにちは。webエンジニア社会人をしている [ningenMe](https://twitter.com/ningenMe) です。

タイトル通り、assignees設定を自動化します。  
下記のことを行います。

- プルリクエストを作った人を自動で `assignees` にする
- github actionsで処理を行う
- yamlではパースなどを自分で書かずに、[GitHub Actions公式](https://github.com/actions) のものを使う

## GitHub
実際に動くソースはこちら

- [assignees-sample.yml](https://gist.github.com/ningenMe/3380446f230ad2919e4f5d759961a106)

```yaml
name: assignees-sample

on:
  pull_request:
    branches: [ main ]

jobs:
  assignees:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - uses: actions/github-script@v4.1.0
        if: github.event_name == 'pull_request'
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            github.issues.addAssignees({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              assignees: `${{ github.actor }}`
            });
```

### UI上でどうなるか
botがassignしてくれます
![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/246454/59d65a1f-d65d-101e-ae92-03f2b7083a77.png)

PRの右側らへんを見るとassigneesが付いているのがわかります。
![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/246454/a84b32af-6d51-d433-2ff6-ea21916ac693.png)


## 説明
説明と言うほど説明することはないです。  
[actions/github-script](https://github.com/actions/github-script) という便利なものがあるのでそれを活用します。
バージョンは 2021/09/14 時点での最新のものを記載しています。  
実際に使う場合は https://github.com/actions/github-script/tags で最新を確認すると良いと思います。

## 先行研究
- [GitHub Actions でプルリクエストの自動アサインをする](https://qiita.com/hkusu/items/39eb92dbd4d6db8a14d8)
- [PR の assignees が空だったときに自動アサイン](https://zenn.dev/snowcait/articles/d6bc5eafd8ab75)

一応上記とはやり方が別になっていると思います。大した処理ではないのでなんでも良い気はします。


## さいごに

超ライトな記事でした。  
ではでは。
