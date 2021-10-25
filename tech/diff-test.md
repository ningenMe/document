# github actionsを使って特定のディレクトリに差分があるときにテストを行う

## はじめに
こんにちは。webエンジニア社会人をしている [ningenMe](https://twitter.com/ningenMe) です。

タイトル通り、特定のディレクトリのみの差分を検知して、それに応じてciでテストを回します。
下記のことを行います。

- 指定したディレクトリに差分があるときにのみ、ciでテストを行う
- 逆に、指定されたディレクトリに差分がないときは、ciでテストをスキップする
- ciでテストをスキップしてもマージ可否には影響させないようにする
- github actionsで処理を行う

ユースケースとしては、フロントとバックエンドが共存してるようなwebのモノレポを想定しています。

## GitHub
実際に動くソースはこちら

- [ningenMe/github-actions-diff-test-sample](https://github.com/ningenMe/github-actions-diff-test-sample)

例として、ルートディレクトリに `./frontend` , `./backend` のディレクトリがある前提のリポジトリを考えます。

`ci.yml`

```yaml
name: ci
on:
  - pull_request
jobs:
  frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: ./.github/workflows/composite/diff
        name: diff
        id: diff
        with:
          subdir: frontend
      - uses: actions/setup-node@v2
        with:
          node-version: 14.x
      - name: test
        if: steps.diff.outputs.diff-count > 0
        working-directory: ./frontend
        run: | 
          yarn install
          yarn test --watchAll=false
  backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: ./.github/workflows/composite/diff
        name: diff
        id: diff
        with:
          subdir: backend
      - uses: actions/setup-java@v2
        with:
          java-version: '11'
          distribution: 'adopt'
      - name: test
        if: steps.diff.outputs.diff-count > 0
        working-directory: ./backend
        run: gradle clean test
```

共通処理はcompositeに切り出しています  

`composite/diff/action.yml`

```yaml
name: diff
description: diff
inputs:
  subdir:
    required: true
outputs:
  diff-count:
    value: ${{ steps.diff.outputs.diff-count }}
runs:
  using: composite
  steps:
    - id: diff
      env:
        TARGET_BRANCH: ${{ github.base_ref }}
      run: |
        git fetch origin ${TARGET_BRANCH}
        count=`git diff origin/${TARGET_BRANCH} HEAD --name-only --relative=${{ inputs.subdir }} | wc -l`
        echo "::set-output name=diff-count::$(echo $count)"
      shell: bash
```

## github actions上でどうなるか

---

- backendにだけ差分があるとき
  - pull request: [#2](https://github.com/ningenMe/github-actions-diff-test-sample/pull/2)  
  - github actions: [checks](https://github.com/ningenMe/github-actions-diff-test-sample/pull/2/checks)   

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/246454/d01ec39b-7f6a-ed1e-80a7-aff9378b8cf7.png)
backendのみテストが走る。


---

  
- frontendにだけ差分があるとき
  - pull request: [#3](https://github.com/ningenMe/github-actions-diff-test-sample/pull/3)  
  - github actions: [checks](https://github.com/ningenMe/github-actions-diff-test-sample/pull/3/checks)   

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/246454/195d4221-2336-1d76-6119-e63cd8dd4be2.png)
frontendのみテストが走る。

---


- frontend/backend両方に差分があるとき
  - pull request: [#4](https://github.com/ningenMe/github-actions-diff-test-sample/pull/4)  
  - github actions: [checks](https://github.com/ningenMe/github-actions-diff-test-sample/pull/4/checks)   

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/246454/24d6090a-1616-8145-ccae-c4052304cc67.png)
frontend/backend両方にテストが走る。


---
  

- frontend/backend両方に差分がないとき
  - pull request: [#5](https://github.com/ningenMe/github-actions-diff-test-sample/pull/5)  
  - github actions: [checks](https://github.com/ningenMe/github-actions-diff-test-sample/pull/5/checks)   

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/246454/603af554-dc5a-36b3-a7b7-41264cb6dc44.png)
両方テストがスキップされる。

------

実行時間を見ると適切にスキップされてるのが分かります。


## 説明

基本的には難しいことはしていないです、gitコマンドで頑張って差分を確認します。
`subdir`に差分を検知したいディレクトリ名を指定します。  
例では`frontend`,`backend`で分けていますが、他のユースケースでも使えると思います。  
また、job自体はスキップせずstep単位でスキップしているため、スキップしたとしてもマージ可否には関わらないです。 



ここではcompositeでの共通処理に関してはここでは説明しません。  https://docs.github.com/ja/actions/creating-actions/creating-a-composite-run-steps-action を読むと良さそうです。


## 先行研究
- [GitHub Actions で変更があるときだけ git commit & push する](https://zenn.dev/snowcait/articles/18c9137f49e378)  
- [GitHub ActionsでPRの差分ファイルだけテストする方法](https://tech.yutaka0m.com/entry/2020/05/30/327/)  

先行研究も本質的には近いことをやっている気がします。


## さいごに

処理がオレオレな書き方になってるのがいけてない感じはしますね、より良い改善案が見つかればまた更新しようと思います。  
ではでは。

