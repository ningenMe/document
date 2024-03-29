# コードレビューで普段意識していること、してもらっていること

## はじめに
こんにちは。webエンジニアの [ningenMe](https://twitter.com/ningenMe) です。

この記事は [Spring Advent Calendar 2022](https://qiita.com/advent-calendar/2022/spring) の 19 日目の記事です。

本記事では僕が普段レビュワーとして、コードレビューで気をつけていること。またレビュワーをするようになった経験からレビュイーとしてPullRequestを作る際に気をつけていること、PullRequestを作ってもらう際にお願いしていること、を書きます。


直近では半年で650個ぐらいのPRを見ていて、エンジニアリングをする時間の中でコードレビューの比率が上がってきたこともあり、その中で色々思ったり工夫した点を書いていきます。


なお普段はspring-bootで構成されるアプリケーションのソースを読むことが大半のため、spring-bootに焦点があたった内容に少し偏るかもしれません。悪しからず。



## 大前提

これはレビュワーに立つ経験が少ないときは気づいていなかったことですが、コードは書く量より読む量の方が多いのである............。



## PullRequest (PR) について

### できるだけdiffの小さいPRだと嬉しい
大前提ですが、小さいPRほど嬉しいです。差分を小さいほどレビュワーのコストは小さく、またスピード感のあるレビューができるため早くマージもでき、レビュワーレビュイーお互いにとってwin-winです。

これはコードレビューする側、される側両方の努力が必要です。

レビューする側は、そもそもの実装の単位を小さくしてもらうために、チケットを細かく分割して誘導や、あらかじめ実装前に実装者とコミュニケーションをとり、認識を合わせましょう。レビュワーが受け身で待ってPRが大きくて見れない、というのは少しディスコミュニケーションな感じがします。

例. apiの実装の際、リポジトリ層やコントローラーでPRを分けて出してもらう。など。

またレビューされる側も、実装途中でdiffを確認し、あまりにも大きいPRになりそうなら途中でPRを一度出してマージするなど、粒度を意識した実装をしましょう。

### 大きいPRはダメ？
そんなことはないと思っています。意味のあるまとまりや、機械的な変更なら、diffが大きくなることは良いと思っています。

例. パッケージ(ディレクトリ)名の変更で、配下のファイル全てに変更が入るなど。

また、アトミックに変更しないとテストが通らない大きなPRというのも場面としては存在するとは思います。必要な範囲の中でできる限りPRを小さくする意識を全員で持つのが大事かなと思います。

### テストを通しながら小さな差分を積み重ねる
たまに、PRを作ったもののテストが通せないという人がいます。そういう事態を防ぐために、コミット単位ぐらいで良いので、こまめにテストを回しましょう。常にテストが通る単位でコミットを重ねると、どの履歴に戻ってもgreenな状態で修正が楽だと思います。またそういう所作をしてなかった時のトラブルシュートとしては、まずテストが通らないことを相談する前に、派生元のコミットまで戻ってテストを動かしてみましょう。自分のコミットの追加によりテストが落ちたのか、そうでないのかの切り分けをするのが良いです。(すぐ有識者に聞いてしまう方が良い場面もあるとは思うので、質問がダメというわけではないのが難しいところ...)


### でも実装始めたらdiffは大きくなるものだし、一気に実装した方が効率良いのでは？
実装を一足飛びにやるのは効率が良いとは自分も思います。ただそれを1つのブランチでまとめてしまうのは話が別かなと感じます。

例えばAPIを1本、ルーティング部分からdb側の処理まで書くような場合に、一旦動くところまで書いてしまうのはアリだと思います。ただその後、意味のある単位でコミットを分けたり、ブランチを分けてPRを出すことが必要で、まず依存の深い方やコアな部分からPRをマージしていくことでコードレビューも局所に集中でき、また粒度を意識した実装にもつながるかなと思います。

40ファイルのchangeとかで、ロジック沢山だと、レビューできないことはないものの修正も無限に発生し、コメントの往復も1週間以上続いたりとレビュワーレビュイーともに疲弊してしまうみたいなパターンをよくみます。

diffがどれぐらいだと多いか、というのは主観ですが、自分は10file changeを超えるようなPRはほとんど出すことがないかなというような所感です。


### 大枠を先にコミットして、骨格を作る意識を持つ
レビューやPRというよりは実装の話になりますが、IFだけを先に合わせたスケルトンを作ろうという話です。

実際10file以下のPRのみで構成しようと思うと少し難しさがあると思います。なのでまずは骨子だけで良いので、サービスクラスのガワや、モデリングのガワだけを作っていき、実装上での各クラスのリレーションや、メソッドのIFだけを先に確定させていくのが大事です。
極論この時点では戻り値は全部nullなどの適当なもので良いので、IFだけ合わせて行って残りをTODOで丸投げしていくのが大事です。こうすることで、常に小さいPRの集合で実装を組んでいくことができる、かつ大枠も先に見えるので、ブレが少ないものが出来上がります。

DDDとかだとドメインモデルから構築するのが一般的かなと思いますが、その過程の中でもモデリングのリレーションだけ先に決めるようなイメージですね。



### 実装は果たして、簡単なタスクだろうか？


上記を踏まえて、実装は果たして簡単なものでしょうか？
1つのDBテーブルをCRUDするAPIをレビュワーのことも気にせず実装するだけなら、そのクオリティはさておき難易度は高くないかもしれません。

ただ、常に小さいPRになるように心がけ、また先に骨子を作るような、大枠をイメージした上でパーツを組んでいくような実装をすることは果たして簡単でしょうか...？


結論としては「そんなことはない」です。


アプリアーキテクチャと呼ばれるような、実装レベルの設計は実装者もレビュワーも理解していないとなかなか難しいところがあります。

意図的に小さいPRを作る、というのもアプリアーキテクチャの理解度が低い場合は少しハードルが高いでしょう。

そんなことを気にするなら動くものをさっさと作って頑張ってレビューしてもらう方が良い、という反論もあるかもしれません。

これはプロジェクトなど業務においては正しい場面もあるかもしれないですが、純粋に質を高めるという観点では少し辛いところではあります。

大きいPR、本当に丁寧にレビューできますか？

また、そういうPRを出してもいいというチームは、レビュワーの方は本当にちゃんと見てくれていますでしょうか？


チーム文化的なところも大きいので一概にgood/badは言えないですが、コードの品質に重きをどこまで置くか次第なのかなあと思います。



これは設計などが上流の過程と称される一方で、実装が下流と称されてしまう部分に対しての警鐘の意味も込めて、実装は難しいという話をしたかった感じです。


ちなみに、一連の流れ全部を書いてもらわないと部分的な処理だけではレビューできない、という意見もあるのかなと思うのですが、その場合はそもそもどういうPRが来るかレビューする側もちゃんと想定できていない、というのが一つ原因にあるのかなと思います。

実装自体はクリエイティブな部分もあるので、完全にオーケストレーションするのは難しいと思いますが、一方でPRで初めて実装者側の意図や思想を知る、というのは手戻りが多くなるケースが多いと思うので、先にお互い実装するものをイメージ合わせた上でPRのフェーズに入る、というのが大事かなと思います。


### レビュイーは説明を書きましょう
これはまあ作法的な部分もあるんですが、作ったPRに対して実装者側の説明が多いとレビュワーとしては嬉しいという感じです。
例えば
  - 設計書のドキュメントを記載する
  - DBなどが絡む場合は、ddlやスキーマのドキュメントを記載する
  - また、会社や業務などの場合は、仕様書などのドキュメントを記載する
  - 何かしらの技術調査の場合は、調査した資料を記載する

など。まあ関連する情報は全部載せてほしいって感じですね。実装の際参考にした記事などもあると嬉しいですね。

また、実装に対して、セルフコメントをつけるは結構有用かなと思います。実装に残すほどのコメントではないときに、PRで自分でインラインコメントをつける感じですね。

後はセルフレビューを行うことも大事かなと思います。PRを作った後すぐコードレビュー依頼を出すのではなく、一度自分もレビュワー目線になって自分のPRを見てみるという感じです。

些細なtypoや、改行忘れなど非本質なミスはレビューの中でノイズになってしまうので、予め排除できると良いですね。

## コードレビューについて

### 機械的なコメントを残す
よくあるやつですが [nits], [must] , [ask] とかをコメントのprefixとして徹底すると意図が伝わりやすくて良いと思います。

- https://qiita.com/kamihork/items/be0d7bdad8ae5a8082fb

### 作法レビュー
コードレビューは自分の中で4種類ぐらいはタイプがあるかなと思っています。
ここでは適当に「作法レビュー」「頑張りレビュー」「ドメインレビュー」「スキルフルレビュー」と名前をつけてあげていきます。(他にも色々コンテキストがあるような気がします、4つに分類される、って言いたいわけではなくパッと思いつくのが4種類あったって感じです)


ここでは「作法レビュー」について。

作法というと気難しさがありますが、いわゆる機械的に見れるやつですね。レビュワーとしても楽なので初手これを見ます。非本質なことが多いですが。

  - コーディングルールを守れているか？
    - これはチーム特有のルールがある場合に守れているか、という感じです
  - フォーマッタ違反していないか
    - これはciで見るべきなのでレビューで見てたらおかしいというのもあります
  - typoしていないかどうか
    - IDEで見ると大体わかる
  - `No Newline at End of File` 。改行忘れ。
    - editorconfigを入れたりエディタでなんとかしたりと仕組みで防げるやつですね
    - https://qiita.com/naru0504/items/82f09881abaf3f4dc171
  - snake_case などの文体
    - クラス名はパスカルケース、変数名はキャメルケース、など。なんでもいいのでそのリポジトリ内で秩序を持って統一できてるのが大事だと思います。名前は疎かにしてはいけないので地味なようでかなり大事
    - staticなものや環境変数は大文字スネークケースにする、など (goだとそんなこともないですが...)
  - コピペミス
    - yamlとかでよくあるやつですね。開発環境用のものをそのままコピペして、本番用にしたりして、微妙に修正が漏れてたりとか。
    - 「devのファイルとの差分はここです」みたいなものをインラインコメントで残していくのが所作としてはおすすめ。
  - 使ってない変数を消す
    - エディタとか、コンパイラが叱ってくれるもののレビューする際にも機械的に見れるはずです

など。
まだまだあると思いますが、いわゆるある程度答えが決まってて、明らかなミスっぽいものを探すのが作法レビューという感じです。

ちなみにこれはそこまでスキルを問わないと思うので、基本的にはレビュイー側も自分で極力見つけて、このやりとりは発生しないようにできるのが望ましいかなと思います。
本質のレビューから入れるのが理想的ですね。

### 頑張りレビュー
「頑張りレビュー」について。
これは少し定義がふわっとしてるんですが、頑張って行うレビューにあたります。

- 例. テストの実装の際に、テスト用のsqlファイルが間違っていないかどうか
- 例. テストの期待値が決まっているケースに対して、意図通りのassertが行われているかどうか
- 例. フロントでのエラー文言を実装する際に、仕様書通りに一言一句正しいかどうか。

など。
少し表現が難しいのですが、ちゃんと見る必要があるものの大変だったり、スルーしてしまう人がたまにいるようなレビューという感じです。

自分の経験の中だと、例えば一気通貫したintegration-testなどを書くと、inputとoutputが両方複雑になることが多いので、「頑張りレビュー」がよく発生します。

### ドメインレビュー
「ドメインレビュー」はまあその名の通りで、ドメイン知識をフル活用するレビューです。

- 業務側の仕様書通りになっているか
  - これはいわゆる開発者側の設計書通りかどうか、ではなく、業務側の仕様書や企画書通りの動きになるか、という意味合いです。
- 開発者側の設計通りになっているかどうか
  - 開発者の設計通りになっているかももちろん含まれます。実装側だけ眺めてると設計書通りになっていなかったり処理が漏れていることに気づかなかったりします
- 正常形やエラーのハンドリングは適切か
  - ドメインと関係ないようで、かなり大事です。特にマイクロサービス文脈だと、ここでこのエラーが起きた場合に、どこまで影響があるんだっけ？とか伝播の度合いを意識したりするので、ドメイン知識がかなり必要になってきます。
- データの値域について
  - 自チームで定義しているドメインデータの場合は実装にある値が全てですが、例えば他領域のデータを参照する場合に、とりうる値が想定している範囲で収まっているか、を確認したりと。
  - 例. `type` というデータ は `hoge` か `fuga` かの2種類の値を取るつもりの実装をしていたが、実は`piyo` も取りうるので考慮しましょう、みたいな。


### スキルフルレビュー
「スキルフルレビュー」雑多な言い方ですが、言語特有の知識だったり、セキュリティやネットワークなどCSそのものの知識が必要なレビューです。

僕も全然知識ないので悩ましいところですが、いわゆる一番本質的なレビューかなと思います。
一番と言いましたが、業務だとドメインレビューの方が大事な場面も多いかもです。(何が本質かは場面によって変わる)

- (java特有ですが) 不要にnullableにしていないか 
  - lombokで@NonNullをつけたり、kotlinだと意味のないoptionalはやめよう、という感じ
- (java特有ですが) finalをつけているかどうか
  - immutableを徹底しているかどうかですね
- (java特有ですが) streamを適切に使えているか
  - for文でガチャガチャするよりはstreamで処理する方がimmutableに自然に扱えてベターなことが多いです
  - javaじゃないにしても、immutableにlistを扱うという観点では同じですね
- 計算量・パフォーマンスは適切か
  - 競技プログラミング的な計算量がまず挙げられますね
  - また、実際はweb文脈だと計算量というよりはパフォーマンスが大事なので、sqlの発行回数とか、外部apiのリクエスト回数を見たりすることも多いと思います
  - dbとのコネクションを使う処理は、sqlではO(1)相当のようなものでもアプリケーション目線では定数倍がめちゃめちゃ重い、みたいな感覚でいるとokな感じがします。ケースバイケースですが。
  - バルクで処理するように修正しましょう、とかもよく上がるケース
  - ロックまわりは変ではないかとかも上がるケース
    - これレビューだけで見るの難しいときもある
- DRY原則を守れているか
  - 論争になりがちなので断定的には言いづらいですが、まあdryにする必要がある、かつ可能なところはやりましょうと。
  - なんでもdryにした方がいいって話をしたいのではなく、コード全体を把握したレビューをしましょう、の意味合いです
  - 結局コード内で共通化するべきか否か、というのはソース全体をある程度把握していないと判断がつきづらい
- アプリアーキテクチャの設計通りになっているか
  - ディレクトリ構成や、モジュールの依存関係、また実装されたものがレイヤー責務外れていないかなど(controllerからsql直接投げてないかとか)
- モデリングが適切かどうか
  - これがコードレビューの中でかなり大事なパートに感じます
  - 例. あるデータとデータの関係が 1:1なのか、あるいは1:nなのか、またそれを的確に実装に落とし込めているか
  - true/falseの2値で表現しようとしてるが、実は3値あるものなのでenumが適切ではないか
  - 新しくステータス用のデータを定義する際に、そのステータスは背反なものになっているかどうか
  - などなど。モデリングもミスが大きな歪みを生むのでここを重点的にレビューするのが大事かなと思います
- スレッドセーフかどうか
  - (spring boot特有かもですが) diコンテナに乗るクラスに状態を持たせていないか、など
    - こういうのはフレームワークと言語知識がないと見落とすので、難しいと感じます
- 脆弱性がないかどうか
  - これも大事です。重点的に見ます。(まあ脆弱性ちゃんとわかったら苦労しないので難しいところですが)
  - 自由文字入力が、sqlに到達するかどうか
    - 例えばソートしてレスポンス返すようなAPIで、asc/descをリクエストで指定するような仕様の場合にasc/descをリクエストで文字列でもらう想定でそのままsqlに使っている、みたいなパターンとかが挙げられます
    - enumに直したり、エスケープしましょうね、という基本の話ではあります
  - apiに認証・認可がかかっているかどうか
    - 直叩きできるようになってるので危険、とか認証はされてるけど認可されてないからログインしたら誰でも人のリソースをみれる、とか。
    - ブラウザ側だけ制御して守るのは意味ないってのが共通認識じゃない時がたまにある
  - 個人情報を扱っていないか、扱っている場合マスキングしているか
    - 会社のルールにもよるけど、識別子に対して生文で使っていいんだっけ？みたいな所作もレビューポイント

など。まだまだレビュー観点はありますが、とりあえず意識的に見るだけでもこれぐらいはあるなあと。

## マインド
ここからはチーム開発におけるマインドの部分に焦点を当てます。

### レビューできなくてもコードレビューに参加しよう
コードレビューはテックリードや、ベテランの方がするものという認識の人が、一定数いたりしそう？自分は昔そうでした。

結論これはよくなかったなと感じています。コードレビューはレビューする側だけでなく、レビューを学んだり、人が指摘されているのを見て自分に跳ね返す場でもあるなと。

まず大前提として、コードレビューをしないとコードレビューはなかなかできるようになりません。実装と同じく、やらないと身につかないのです。

また、コードレビューの経験や、レビューしやすいPRへの意識を持つことで、実装をする際にもクオリティの向上や、気づきが生まれると思います。

またコードレビューは実装を題材にしたコミュニケーションの場でもあるので、わからない部分は質問をしたり、すごい実装を見たら褒めたりなど、活発に全員で行っていけるのが理想的かなと思います。関心がないと学ぶフェーズまで辿り着けないんですよね。(忙しかったり工数が厳しいと難しいこともありますが)

あとコードレビューに参加することで、他の人が言われていた指摘を事前に防ぐことができるなどナレッジの横展開の側面もあります。


あと一番大事なこととして、コードリーディングを増やすのが大事というのがあります。リポジトリ内で詳細を把握しているソースや大枠を把握している範囲を増やすことは、その後の実装の際にもかなり活きて来ます。似た処理があの辺にあったな、とか。パッケージ構成はここと同じ感じになるはず、とかそういう。

関係ないリポジトリでも読めるならたくさんソースを読むのがおすすめです。PRという話に限らずソースリーディングはかなり大事だなと思います。読んだことない処理は書けなかったり、思いつかないことが多いです。

### レビュワー側はマージまでの速度を高めよう
レビュワーが基本的には立場的にパワーを持ってしまうことが多いと思うのですが、PRをマージするにはレビュイーの努力だけではなくレビュワーの努力もかなり大事と思います。レビュワーの動きこそが、PRをマージまで運ぶのです

- 完璧を求めず、マージしちゃうのも大事
  - 1つのPRでやりとりが多いと疲弊しますし、レビュイーのモチベーションも下がります
  - 非本質だったりクリティカルではないミスが、後でさらに修正を加えてもらう前提で一旦マージするのも大事だと思います
  - いっぱいやり取りしてapproveも集まって来たのに、些細なミスを指摘されると辛い、みたいな。
  - 大きいPRは特に、一旦マージすることを目標としないと差分が多くて辛い
  - 微妙な修正はTODO送りにしたりバックログにどんどん入れていきましょう
- そのためのリリースブランチ
  - 一時的なマージを許容できるように、ブランチ戦略でカバーするのが良いかなと思います
  - リリースブランチを育てていくみたいなのが、小さいPRをたくさん作るのと相性いいかなと思います
    - 小さいPRを作る戦略は、テストはもちろん通る状態でマージしていくものの、アプリケーションとしては成り立っていない状態も多々あるので
- マージのテンポは開発効率につながる
  - PRを作ってからマージをするまでの速度がかなり大事かなと思います
  - 早くマージしないと、他の人の作業がブランチへ入っていくので、ブランチの状態に変換が入ってしまい、レビュイー側の負担が増えてしまう
  - 小さいPRを積み重ねることで、差分がすぐブランチへ吸収されていき、多人数開発にも強くなる
  - レビュワーは早くPRを見ましょう
    - チーム文化にもよりますが、レビュー依頼がきたら極力早くレビューをすること。レビュイー側の動きを止めないような意識が大事です。


## さいごに
以上、コードレビュー論でした。
かなり長文になってしまいました。
主観が強いので的外れな部分もあるかもしれないですが、テックリードをする立場の人や同じようなロールの方にとって参考になる部分があれば幸いです。

ではでは。