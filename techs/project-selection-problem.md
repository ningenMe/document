# 燃やす埋める問題 辺の張り方チートシート
実装メインの話をします。理論の話はないです。
曖昧な表現が多いです。厳密な話はしないので悪しからず。
燃やす埋めるではなくproject selection problemと捉えるべき、の話も触れません。

## 準備

下記のように定義します。

- $S$ : 始点
- $G$ : 終点

フローの実装は下記参考
https://ningenme.github.io/compro-library/lib/graph/Dinic.cpp

- make_edge( $from$ , $to$ , $cap$)
  - 頂点 $from$ から頂点 $to$ へ、容量 $cap$ の辺を張ります。
  - 使うメソッドはこれだけです。

## 辺の張り方

|条件|処理|
|-|-|
| $i$ が $0$ のとき $c$ 失う|make_edge($i$,$G$,$c$)|
| $i$ が $1$ のとき $c$ 失う|make_edge($S$,$i$,$c$)|
| $i$ が $0$ のとき $c$ 得る|先に$c$を得る<br>make_edge($S$,$i$,$c$)|
| $i$ が $1$ のとき $c$ 得る|先に$c$を得る<br>make_edge($i$,$G$,$c$)|
| $i$ が $0$, $j$ が $1$ のとき $c$ 失う|make_edge($i$, $j$, $c$)|
| $i$ が $1$, $j$ が $0$ のとき $c$ 失う|make_edge($j$, $i$, $c$)|
| $i$ と $j$ が異なるときc失う|make_edge($i$, $j$, $c$)<br>make_edge($j$, $i$, $c$)|
|$i$ が $0$, $j$ が $0$ のとき $c$ 得る|先に $c$ を得る<br>make_edge($S$, $k$, $c$)<br>make_edge($k$, $i$, $inf$)<br>make_edge($k$, $j$, $inf$)|
|$i$ が $1$, $j$ が $1$ のとき $c$ 得る|先に $c$ を得る<br>make_edge($i$, $k$, $inf$)<br>make_edge($j$, $k$, $inf$)<br>make_edge($k$, $G$, $c$)|
二部グラフに関しては状態を反転させることで、他の条件も上記の式に帰着させることが出来るときがあります。

## 問題
以下、実際の実装例を挙げていきます。


---
####  [E - MUL](https://atcoder.jp/contests/arc085/tasks/arc085_c)   
「割る」: $0$, 「割らない」: $1$,と割り当てる

|||
|-|-|
|$i$ が $1$ のとき $abs{(A_{i})}$ 得る|先に $abs{(A_{i})}$ を得る<br>make_edge($i$, $G$, $abs{(A_{i})}$)|
|$i$ が $1$ のとき $abs{(A_{i})}$ 失う|make_edge($S$, $i$, $abs{(A_{i})}$)|
|$i$ が $0$、$j=m*i$ が $1$ のとき、$inf$ 失う|make_edge($i$, $j$, $inf$)|

[提出](https://atcoder.jp/contests/arc085/submissions/21855433)

---
####  [F - Zebraness](https://atcoder.jp/contests/abc193/tasks/abc193_f)   
$i+j$ の $parity$ が $0$ のとき、「白」:$0$, 「黒」:$1$ ,と割り当てる  
$i+j$ の $parity$ が $1$ のとき、「黒」:$0$, 「白」:$1$ ,と割り当てる  

||||
|-|-|-|
|$parity=0$|$x$ が $0$ のとき $b$ 得る|先に $b$ を得る<br>make_edge($S$, $x$, $b$)|
|$parity=0$|$x$ が $1$ のとき $w$ 得る|先に $w$ を得る<br>make_edge($x$, $G$, $w$)|
|$parity=1$|$x$ が $1$ のとき $b$ 得る|先に $b$ を得る<br>make_edge($x$, $G$, $b$)|
|$parity=1$|$x$ が $0$ のとき $w$ 得る|先に $w$ を得る<br>make_edge($S$, $x$, $w$)|
||$x$ が $0$, $y$ が $0$ のとき $1$ 得る|先に $1$ を得る<br>make_edge($S$, $k$, $1$)<br>make_edge($k$, $x$, $1$)<br>make_edge($k$, $y$, $1$)|
||$x$ が $1$, $y$ が $1$ のとき $1$ 得る|先に $1$ を得る<br>make_edge($x$, $k$, $1$)<br>make_edge($y$, $k$, $1$)<br>make_edge($k$, $G$, $1$)|

[提出](https://atcoder.jp/contests/abc193/submissions/21876523)

---
####  [No.1479 Matrix Eraser](https://yukicoder.me/problems/no/1479)   
行: 「操作を行う」:$0$,「操作を行わない」:$1$ と割り当てる  
列: 「操作を行わない」:$0$,「操作を行う」:$1$ と割り当てる  

|||
|-|-|
|$i$ が $0$ のとき $1$ 失う|make_edge($i$, $G$, $1$)|
|$j$ が $1$ のとき $1$ 失う|make_edge($S$, $j$, $1$)<br>ここで実装上は $j=j+H$ である|
|$i$ が $1$,$j$ が $0$ のとき $inf$ 失う|make_edge($j$, $i$, $inf$)<br>ここで実装上は $j=j+H$ である|

[提出](https://yukicoder.me/submissions/649636)

---
####  [E. Bricks](https://codeforces.com/contest/1404/problem/E)   
マスとマスの間の辺を頂点とみなす。  
$x$ 軸に平行な辺: 「マスを連結する」:$0$,「マスを連結しない」:$1$ と割り当てる  
$y$ 軸に平行な辺: 「マスを連結しない」:$0$,「マスを連結する」:$1$ と割り当てる  

|||
|-|-|
|$a$ が $0$ のとき $1$ 得る|make_edge($S$, $a$, $1$)|
|$a$ ($x$ 軸平行)が $0$, $b$ ($y$ 軸平行)が $1$ のとき $inf$ 失う|make_edge($a$, $b$, $inf$)|
|$a$ ($y$ 軸平行)が $1$, $b$ ($x$ 軸平行)が $0$ のとき $inf$ 失う|make_edge($b$, $a$, $inf$)|

[提出](https://codeforces.com/contest/1404/submission/113435436)

---
####  [No.957 植林](https://yukicoder.me/problems/no/957)   
行/列に対して「植える」:$0$, 「植えない」:$1$ ,と割り当てる。  
また、行側の利得を貪欲に先に選んでしまうことで、行列のコストを行側に押し付けることが出来る。そうすることで辺の数のオーダーが落ちる

|||
|-|-|
|$i$ が $0$ のとき $abs{(R_{i}-cost)}$ 失う|make_edge($i$, $G$, $abs{(R_{i}-cost)}$)|
|$j$ が $0$ のとき $abs{(C_{j})}$ 得る|先に $abs{(C_{j})}$ を得る<br>make_edge($j$, $G$, $abs{(C_{j})}$)<br>ここで実装上は $j=j+H$ である|
|$i$ が $1$, $j$ が $0$ のとき、 $abs{(grid_{i,j})}$ 失う|make_edge($i$, $j$, $abs{(grid_{i,j})}$)<br>ここで実装上は $j=j+H$ である|

[提出](https://yukicoder.me/submissions/649584)

---

## 参考資料
- [燃やす埋める問題](https://ei1333.github.io/luzhiled/snippets/memo/project-selection.html)
- [燃やす埋める問題を完全に理解した話](https://koyumeishi.hatenablog.com/entry/2021/01/14/052223)
- [燃やす埋める問題](https://ikatakos.com/pot/programming_algorithm/graph_theory/maximum_flow/burn_bury_problem)
- [最小カットとProject Selection Problemのまとめ](https://kimiyuki.net/blog/2017/12/05/minimum-cut-and-project-selection-problem/)
- [『燃やす埋める』と『ProjectSelectionProblem』](http://tokoharuland.hateblo.jp/entry/2017/11/12/234636)
- [LPとグラフと定式化](http://tokoharu.github.io/tokoharupage/docs/formularization.pdf)
- [続：『燃やす埋める』と『ProjectSelectionProblem』](http://tokoharuland.hateblo.jp/entry/2017/11/13/220607)
- [最小カットについて](https://yosupo.hatenablog.com/entry/2015/03/31/134336)
