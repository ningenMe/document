# terraform 運用失敗談


## はじめに
こんにちは。webエンジニアの [ningenMe](https://twitter.com/ningenMe) です。  
この記事は [terraform Advent Calendar 2021](https://qiita.com/advent-calendar/2021/terraform) の 9日目の記事です。

terraformの良い使い方の話はたくさん記事があると思ったので、今日は `良くない` 使い方に焦点を当てていきます。  
terraformを実際に運用していて思ったバッドプラクティスを挙げていきます。
バッドと勝手に表現している部分に気を悪くした方がいたらすみません。

## 前提
この記事の本題ではないので是非とかは述べません。一応話する上での前提知識。

- AWSリソースを terraform で扱う
- 開発環境はローカルからマージ前に apply をして良い
- 本番環境はマージ後に、github actions からのみ apply をして良い

## パッケージ構成
この記事の本題ではないので是非とかは述べません。一応話する上での前提知識。

```shell
./
├── env
│   ├── hoge-component
│   │   ├── develop 
│   │   │   └── main.tf
│   │   └── production
│   │       └── main.tf
│   ├── fuga-component 
│   │   ├── develop 
│   │   │   └── main.tf
│   │   └── production
│   │       └── main.tf
│   └── piyo-component
│       ├── develop 
│       │   └── main.tf
│       └── production
│           └── main.tf
├── base
│   ├── hoge-component
│   │   └── *.tf
│   ├── fuga-component 
│   │   └── *.tf
│   └── piyo-component
│       └── *.tf
└── module
    ├── ecs
    ├── alb 
    ├── elasticache
    └── etc..
```

- 複数コンポーネントが1リポジトリに相乗りした形になっている
  - tfstateが複数あるような感じ
- env配下のmain文を切り替えて環境差分を作っている
- base配下でresourceを書いていく
- module配下は、各コンポーネントによらない基本的なものの雛形とかを var で渡せる形式で共有して置いている
- 複数コンポーネントは運用者が別なので、複数チームでモノレポを管理しているような状態


### 失敗その1 複数コンポーネントでモノレポ運用していること
ここはそもそも失敗と定義していいか怪しい。是非はあると思うし、モノレポで上手くいっているチームもたくさんあると思う。
辛い部分を挙げると

- マージやapplyをする際に関わる人が多くなる
  - コミュニケーションコストが大きくなる
- 小さいPRでも、一応各コンポーネントのplanを全部見ておこうってなるのでコストが大きい
- moduleに予想外のコミットが知らない間に積まれてて、自分のチームのコンポーネントにも影響が出ることがある

などです。
どれもプロセス改善でなんとか出来ないことはないですが、そもそもモノレポにしなければ考えることもないかなという感じです。

一応モノレポのメリットを挙げます

#### moduleの記述を共有して使いまわせる

とは言ったものの、これに関しては terraform でdry原則とかをコンポーネント跨いでまで意識する必要ないかなというのが感想です。  
規模にもよりますが、別に各チームで同じmodule書いたとてそこまで不便なことはないという感じです。記述量も知れてますし。  
同じようなインフラになってほしい、というのはわかりますが、アプリケーションソースと違ってロジックを持つわけでもないので、共通化するメリット以上に影響範囲が大きいデメリットが上回るかなと。

あとmoduleを使い回す かつ リポジトリは分ける、をやるときに、moduleだけのリポジトリを1個構えて gitのサブモジュールにしてしまう、などがやり方として一つあると思います。


#### ciなどを各チームで作らなくて良くなるので、コスト削減できる
これはまあマイクロサービスあるあるに近い話でもあるのでわかりやすい気もします。  
ただterraformのciってpr時のfmtなどのバリデーション、plan, applyがあれば一旦は事足りるので、そこまでパイプライン大変ではないのですよね。
これのためにモノレポにするのもなんだかなあって感じです。

### 失敗その2 count文を多用したこと
一例を挙げると、下記のような感じです

```terraform
resource "aws_cloudwatch_event_rule" "event_rule" {
  count = length(var.jobs)

  name                = "event_rule_${var.jobs[count.index].name}"
  description         = "job schedule"
  schedule_expression = var.jobs[count.index].cron
  is_enabled          = true
}
```
何かしらの list を渡して、それに対して countで for文を回すような表現ですね

ここは単純に for-each で書きましょうって感じです。
countで書くと、リソースがindexで振られてしまうので、リストの順番を変えるだけで破壊的な差分が生まれます。


　　
　　


「countは途中のリソースを消すとインデックスがずれるという致命的な問題を抱えている」

- [Terraformのfor_eachにmapのlistを渡してループしたい](https://qiita.com/minamijoyo/items/3785cad0283e4eb5a188)

の記事でしっかり書かれているので是非。


改善例を書いておくと下記のような感じです

```terraform
resource "aws_cloudwatch_event_rule" "event_rule" {
  for_each = var.job_map

  name                = "event_rule_${each.key}"
  description         = "job schedule"
  schedule_expression = each.value
  is_enabled          = true
}
```

詳しい使い方とかは別記事参照

- [Terraformでのloop処理の書き方（for, for_each, count)](https://zenn.dev/wim/articles/terraform_loop)



個人的には countはリソースを作るか作らないかのif文だけに徹底するのが良いかなと思います。  
開発環境だけあるリソースを作りたい、とかの場合ですね。



詳しい書き方とかは別記事参照

- [Terraformでcountをifのように使う](https://qiita.com/mia_0032/items/978449a06699ed1abe15)


### 失敗その3 アプリケーションのリソースを可変長にしなかったこと
これ言い方がちょっと良くないですね。  
ユースケースとしては、開発環境だけapiを複数立てて、面を増やしたいみたいなときです。

例えば下記のようなソースです

```terraform
resource "aws_ecs_service" "net_api_ecs_service" {
  name            = "net-api-ecs-service"
  /* 詳細は割愛 */
}
```
何げないecsのserviceのリソースなんですが、これを先程の for-eachも交えて

```terraform
resource "aws_ecs_service" "net_api_ecs_service" {
  for_each = var.service_name
  name            = each.key
  /* 詳細は割愛 */
}
```
のように書いていた方が嬉しいことがある、って感じです。要素が1個だとしても。    
というのも開発の過程で、開発環境が2面必要になった時に、前者の書き方をしていると

```terraform
resource "aws_ecs_service" "net_api_ecs_service" {
  name            = "net-api-ecs-service"
  /* 詳細は割愛 */
}
resource "aws_ecs_service" "net_api_ecs_service2" {
  name            = "net-api-ecs-service2"
  /* 詳細は割愛 */
}
```
みたいな感じで、ハードコーディングが生まれてしまうパターンがあります。  
もちろんちゃんとリファクタすればいいのですが、本番applyの影響とかも考えるとなかなか書き直すのは難しかったりします。  
なので最初から可変長にしておこうというのが主題です。  
もちろん全部のリソースでそんな先を見越した書き方をするのはナンセンスな気もしますが、ある程度ユースケースが見込めるものは綺麗に書いておけると良いのかなと思います。

### 失敗その4 ci/cdからしかapplyを打てないリソースを作ったこと
ちょっと説明が難しいんですが、ciで使ってるサーバーにクレデンシャルとかが乗ってて、その情報を使ってciからしかapply出来ないようなリソースがあることを指します。  
つまりはローカルからapplyすると必ず変更が入ってしまうようなリソースですね。

こういうものが必要になってくること自体はokなんですが、tf-stateを分けておかないと毎回開発の過程で差分が出るので良くないなという話です。
開発環境も本番環境も master(main) と差分0を常に保てるようなterraformにしないとね、って感じですね。

## さいごに
以上、失敗談でした、他にもterraformで日々失敗している気がするので、またエピソードが溜まったら続きを書こうかなと思います。  
この記事を見て同じ失敗をする人が減れば幸いです。  

ではでは。
