# 概要
PRの作り方、コードレビューのやり方。
コードは書く量より読む量の方が多いのである。。。。。。。。

# PR
- できるだけdiffを小さくする
- 意味のあるまとまりや、機械的な変更なら、diffが大きくなることは良いと思う
- アトミックに変更しないとテストが通らない大きなPRというのも場面としては存在する
- テストを通しながら小さな差分を積み重ねる
- レビュワーを意識する
- 実装を一足飛びにやるのは効率が良いと思う、ただそれを1つのブランチでまとめてしまうのは話が別
- 大枠を先にコミットして、骨格を作る意識を持つ
- 実装は果たして、最低レベルのタスクだろうか？
  - そんなことはない
  - 「未知」が含まれるものは設計やマネジメントより難しいこともある
  - 「未知」がないものは、確かにタスクの難易度は低い
- 説明を書く
  - 設計書のwikiをはる
  - テーブルのwikiを貼る
  - specのwikiを貼る
  - 調査結果のwikiを貼る
- セルフコメントをつける
- セルフレビューを行う
- PRが大きくなりそうなら、チケットの粒度を下げる、PRの分割を行う意識を持つ
# コードレビュー
  - "[nits]" 
  - "[must]"
  - "[ask]"

## 作法レビュー
  - できてほしい
  - 主な項目 
  - コーディングルール
  - nonnull
  - final
  - save action
  - typo
  - endline
  - snakeCase などの文体
  - コピペミス
  - 使ってない変数
    - intellijが教えてくれるよ
  - parameterizedTest
  - staticフィールドは大文字スネークケース
## 頑張りレビュー
  - できてほしい
  - 主な項目 
    - テストケースが網羅されているか
    - csvやsqlの中身がテストケース通りになっているかどうか
## ドメインレビュー
  - できてほしい
  - 主な項目 
    - spec通りになっているかどうか
    - 仕様書通りになっているかどうか
    - 200,400,500のハンドリングは適切か
## スキルが必要なレビュー
- できなくても良い
- 主な項目 
  - streamを使えているか、計算量は適切か
  - immutableになっているか
  - dry
  - パッケージ構成は適切か
    - アプリアーキテクチャ
  - モデリングが適切かどうか
  - スレッドセーフかどうか
  - 脆弱性がないかどうか
    - 自由文字入力が、sqlに到達するかどうか
    - apiに認証がかかっているかどうか
    - 適切な認可がかけられているかどうか
    - 個人情報を扱っていないか、扱っている場合マスキングしているか
  - パフォーマンスが出る実装になっているかどうか
    - sqlの分割insert
    - listの2重ループがないか
  - 他の箇所に似た実装がないかどうか
    - 全体を把握する必要があるので難しい
  - ロックまわりは変ではないか
# レビューできなくてもレビューに参加しよう
- 質問をする
- 褒める
- コードを読み、ナレッジを増やす
  - コードリーディングをする量が大事
# 開発速度
- 完璧を求めない
- マージしちゃうのも大事
- そのためのリリースブランチ
- 追って直せばok
- バックログにどんどん入れていこう
- マージのテンポは開発効率につながる
- レビュワーも頑張ること
  - 早くPRを見ましょう
  - マージするためにレビュワーレビュイー両方で頑張る