# 非再起抽象化セグメント木について
c++での実装メインの話をします。理論やモノイドなどの話はないです。  
自分がこう書くと上手く使えてるってだけのtipsを並べます。正当性はあまり担保できません。

## 実装
まずは完成品。  

- 非再起抽象化セグメント木  
	- https://github.com/ningenMe/compro-library/blob/master/SegmentTree.cpp
- 非再起抽象化遅延伝搬セグメント木 
	- https://github.com/ningenMe/compro-library/blob/master/LazySegmentTree.cpp  

## はじめに
再起かつ抽象化してないセグメント木との違いを意識して書きますが、再起のセグ木とも同じ点だったり、抽象化してないセグ木とも同じ点も多々あります。  

以下、データを持つセグメント木の頂点をノードと称する。

- セグメント木をクラスで持つ。2本以上生やすとき大変なので。  
  
- 数列サイズ(length)は内部的には2べきで持つ
	- ノードのサイズは2*lengthになる  
- 1-indexed  
	- topが{1},上から2段目が{2,3},...みたいな  
- 半開区間で書く [l,r)  
- 各ノードの範囲を表すrangeも持つ  
	- range[1]=[0,length),range[2]=[0,length/2),range[3]=[length/2,length),...みたいな  
	- rangeは二分探索しないならSegment Treeでは要らない。Lazy Segment Treeでは必須。
- 二分探索するなら元の数列サイズnumも持つ  
	- 二分探索しないなら要らない。

雛形 


```C++
class SegmentTree {
	size_t length;
	vector<typeNode> node;
	vector<pair<size_t,size_t>> range;
public:
	SegmentTree(){}
	//[idx,idx+1)
	void update(size_t idx, const int var) {}
	//[l,r)
	int get(int l, int r) {}
};
```
## コンストラクタ
3つあると使いやすい。

- 初期化内容はどれもメモリの確保。rangeの計算。遅延伝搬時も一緒。
	- O(N)で処理するのが大事。
- 配列サイズを渡して単位元で初期化  

```C++
	SegmentTree(const size_t num): num(num) {
		for (length = 1; length < num; length *= 2);
		node.resize(2 * length, 0);
		range.resize(2 * length);
		for (int i = 0; i < length; ++i) range[i+length] = make_pair(i,i+1);
		for (int i = length - 1; i >= 0; --i) range[i] = make_pair(range[(i<<1)+0].first,range[(i<<1)+1].second);
	}
```

- 配列サイズを渡して定数値で初期化
	- 単位元じゃない初期化値で初期化したい場面用

```C++
	SegmentTree(const size_t num, const int init) : num(num) {
		for (length = 1; length < num; length *= 2);
		node.resize(2 * length, init);
		range.resize(2 * length);
		for (int i = 0; i < length; ++i) range[i+length] = make_pair(i,i+1);
		for (int i = length - 1; i >= 0; --i) range[i] = make_pair(range[(i<<1)+0].first,range[(i<<1)+1].second);
	}
```

- vectorを渡して初期化

```C++
	SegmentTree(const vector<typeNode> & vec) : num(vec.size()) {
		for (length = 1; length < vec.size(); length *= 2);
		node.resize(2 * length, 0);
		for (int i = 0; i < vec.size(); ++i) node[i + length] = vec[i];
		for (int i = length - 1; i >= 0; --i) node[i] = Op.funcNode(node[(i<<1)+0],node[(i<<1)+1]);
		range.resize(2 * length);
		for (int i = 0; i < length; ++i) range[i+length] = make_pair(i,i+1);
		for (int i = length - 1; i >= 0; --i) range[i] = make_pair(range[(i<<1)+0].first,range[(i<<1)+1].second);
	}
```

ここからセグメント木と遅延伝搬セグメント木で分けます。
# セグメント木
## 非再起
### update

- 一番底を更新した後、ボトムアップで更新する
- (idx<<1)+0,(idx<<1)+1,はidxの2つの子になる

```C++
	//[idx,idx+1)
	void update(size_t idx, const int var) {
		idx += length;
		node[idx] = var;
		while(idx >>= 1) node[idx] = max(node[(idx<<1)+0],node[(idx<<1)+1]);
	}
```

### get

- 左右[l,r)の底から区間を縮めつつ、ボトムアップに値をマージする。
- (l>>1),(r>>1),はそれぞれl,rの親になる

```C++
	//[l,r)
	typeNode get(int l, int r) {
		int vl = Op.unitNode, vr = Op.unitNode;
		for(l += length, r += length; l < r; l >>=1, r >>=1) {
			if(l&1) vl = max(vl,node[l++]);
			if(r&1) vr = max(node[--r],vr);
		}
		return max(vl,vr);
	}
```

## 抽象化


```C++
	void update(size_t idx, const typeNode var) {
		if(idx < 0 || length <= idx) return;
		idx += length;
		node[idx] = Op.funcMerge(node[idx],var);
		while(idx >>= 1) node[idx] = Op.funcNode(node[(idx<<1)+0],node[(idx<<1)+1]);
	}

	//[l,r)
	typeNode get(int l, int r) {
		if (l < 0 || length <= l || r < 0 || length < r) return Op.unitNode;
		typeNode vl = Op.unitNode, vr = Op.unitNode;
		for(l += length, r += length; l < r; l >>=1, r >>=1) {
			if(l&1) vl = Op.funcNode(vl,node[l++]);
			if(r&1) vr = Op.funcNode(node[--r],vr);
		}
		return Op.funcNode(vl,vr);
	}
```

- ノードの型をテンプレートにする。上記で説明した代入やmaxの演算を、外から与える形にする。
- funcNode 取得クエリで欲しい演算
	- ノード同士の二項演算
	- max,min,sum,gcd,xorなどが入るところ。
- funcMerge 更新クエリでしたい演算
	- 外からの値との二項演算
	- add,updateなどが入るところ。
- 結合の順序なども意識する(行列がバグるため)
- 演算をfunctionで渡してもいいが定数倍が遅くなる。
	- どうせ単位元なども外から与えるので、演算とまとめて構造体で渡す設計が良い(下記参照)

```C++
template<class Operator> class SegmentTree {
	Operator Op;                            
	using typeNode = decltype(Op.unitNode); 
	size_t length;
	size_t num;
	vector<typeNode> node;
	vector<pair<size_t,size_t>> range;
/* 
	hoge
*/ 
}

//一点更新 区間最大
template<class typeNode> struct nodeMaxPointAdd {
	typeNode unitNode = 0;
	typeNode funcNode(typeNode l,typeNode r){return max(l,r);}
	typeNode funcMerge(typeNode l,typeNode r){return r;}
};
```

## 二分探索

- セグメント木上の二分探索も非再起で書けます。
	- 普通にやるとlog2個になるところを1個にするテク
- 基本的には貪欲法です。大きく累積を試みて、駄目なら刻む。
	- 直感的にはダブリングLCAの登るパートに近い  

### Prefix Range [0,length)
- 0からの累積値に対しての二分探索です。
	- 左から右に向かっての累積値が単調性を持つことを仮定します。
	- BITとかでやるやつ
- topを見る。その時点でcheck関数がfalseなら右端を返す
	- lengthは内部的な配列サイズなのでコンストラクタの引数で貰ってあるnumを返す。
- トップダウンに見る。
	- 左の子がマージできるならマージして右の子へ移動。
	- 左の子をマージ出来ないなら左の子へ移動。
- 下記実装だと最後index突き抜けてるので2で割る。
- 二分探索でノードと比較したい値を渡して、indexを返す。
	- 比較関数funcCheck()は抽象化クラスに入れておく。

```C++
	//return [0,num]
	int PrefixBinarySearch(typeNode var) {
		if(!Op.funcCheck(node[1],var)) return num;
		typeNode ret = Op.unitNode;
		size_t idx = 2;
		for(; idx < 2*length; idx<<=1){
			if(!Op.funcCheck(Op.funcNode(node[idx],ret),var)) {
				ret = Op.funcNode(node[idx],ret);
				idx++;
			}
		}
		return min((idx>>1) - length,num);
	}
```

### Arbitary Range [l,r)
- 任意範囲での二分探索。
	- 左から右に向かっての累積値が単調性を持つことを仮定します。
	- こちらはPrefix Rangeの上位互換。定数倍は少し重くなる。
- まずlの値(内部的にはnode[l+length]の値)から見てマージしていく。
	- その後右へ右へ進んでいく。
- 二分木の左側の子だった場合、右側の頂点へ。
- 右側の子だった場合は、一段上の右側の頂点へ飛ぶ。
	- この操作により見る範囲が2べきで大きくなるので計算量がlogで収まる。
- check関数がfalse、あるいは範囲がrより大きくマージできないときは一段下の左の子を見る。
	- 一度下がった段より上がることはなくなるため上下の遷移がlogで収まる。

```C++
	//range[l,r) return [l,r]
	int BinarySearch(size_t l, size_t r, typeNode var) {
		typeNode ret = Op.unitNode;
		size_t off = l;
		for(size_t idx = l+length; idx < 2*length && off < r; ){
			if(range[idx].second<=r && !Op.funcCheck(Op.funcNode(ret,node[idx]),var)) {
				ret = Op.funcNode(ret,node[idx]);
				off = range[idx++].second;
				if(!(idx&1)) idx >>= 1;			
			}
			else{
				idx <<=1;
			}
		}
		return off;
	}
```

# 遅延伝搬セグメント木
- 普通のセグメント木違い、区間を覆うlazy配列に一度値を格納し必要な時に伝搬させる。ここが少し複雑。

## 非再起
### update
- トップダウンでlazyを伝搬させる
- 左右[l,r)の底から区間を縮めつつ、ボトムアップに値をマージする。
- l,rを含む区間を全てボトムアップに更新する。

```C++
	//update [a,b)
	void update(int a, int b, int x) {
		int l = a + length, r = b + length - 1;
		for (int i = height; 0 < i; --i) propagate(l >> i), propagate(r >> i);
		for(r++; l < r; l >>=1, r >>=1) {
			if(l&1) lazy[l] = x, propagate(l),l++;
			if(r&1) --r,lazy[r] = x, propagate(r);
		}
		l = a + length, r = b + length - 1;
		while ((l>>=1),(r>>=1),l) {
			if(lazy[l] == 0) node[l] = max(node[(l<<1)+0]=lazy[(l<<1)+0],node[(l<<1)+1]=lazy[(l<<1)+1]);
			if(lazy[r] == 0) node[r] = max(node[(r<<1)+0]=lazy[(r<<1)+0],node[(r<<1)+1],=lazy[(r<<1)+1]);
		}
	}
```

### get

- トップダウンでlazyを伝搬させる
- 左右[l,r)の底から区間を縮めつつ、ボトムアップに値をマージする。

```C++
	//get [a,b)
	int get(int a, int b) {
		int l = a + length, r = b + length - 1;
		for (int i = height; 0 < i; --i) propagate(l >> i), propagate(r >> i);
		int vl = 0, vr = 0;
		for(r++; l < r; l >>=1, r >>=1) {
			if(l&1) vl = max(vl,node[l]=lazy[l]),l++;
			if(r&1) r--,vr = max(node[r]=lazy[r],vr);
		}
		return max(vl,vr);
	}
```

## 抽象化

- ノードの型をテンプレートにする。上記で説明した代入やmax、遅延伝搬の演算を、外から与える形にする。
- funcNode 取得クエリで欲しい演算
	- ノード同士の二項演算
	- max,min,sum,gcd,xorなどが入るところ。
- funcLazy 更新クエリでしたい演算
	- 外からの値との二項演算
	- add,updateなどが入るところ。
- funcMerge 遅延伝搬する際の演算
	- 実際の使い方を見るのがよさそう
	- 区間長を扱えるようにrangeも引数で受け取る
- セグメント木の時に加えて、遅延配列の単位元も与える。
	- nodeとlazyの型は別で持っておかないと応用が効きにくいので分けるのを推奨。

```C++
template<class Operator> class LazySegmentTree {
	Operator Op;                                       
	using typeNode = decltype(Op.unitNode);          
	using typeLazy = decltype(Op.unitLazy);
	size_t num;      
	size_t length;                                   
	size_t height;                                   
	vector<typeNode> node;                           
	vector<typeLazy> lazy;                           
	vector<pair<size_t,size_t>> range;
/* 
	hoge
*/ 
};

//区間最大　区間更新
template<class typeNode, class typeLazy> struct nodeMaxLazyUpdate {
	typeNode unitNode = 0;
	typeLazy unitLazy = 0;
	typeNode funcNode(typeNode l,typeNode r){return max(l,r);}
	typeLazy funcLazy(typeLazy l,typeLazy r){return r;}
	typeNode funcMerge(typeNode l,typeLazy r,int len){return r!=0?r*len:l;}
};
```

## 二分探索
- 遅延伝搬セグメント木上の二分探索も非再起で書けます。
	- 普通のセグメント木と殆ど同じ。
	- 最初にトップダウンでlazyを伝搬させる
	
### Prefix Range [0,length)

```C++
	//return [0,length]
	int PrefixBinarySearch(typeNode var) {
		int l = length, r = 2*length - 1;
		for (int i = height; 0 < i; --i) propagate(l >> i), propagate(r >> i);
		if(!Op.funcCheck(node[1],var)) return num;
		typeNode ret = Op.unitNode;
		size_t idx = 2;
		for(; idx < 2*length; idx<<=1){
			if(!Op.funcCheck(Op.funcNode(ret,Op.funcMerge(node[idx],lazy[idx],range[idx].second-range[idx].first)),var)) {
				ret = Op.funcNode(ret,Op.funcMerge(node[idx],lazy[idx],range[idx].second-range[idx].first));
				idx++;
			}
		}
		return min((idx>>1) - length,num);
	}
```

### Aribtary Range [l,r)
```C++
	//range[l,r) return [l,r]
	int BinarySearch(size_t l, size_t r, typeNode var) {
		if (l < 0 || length <= l || r < 0 || length < r) return -1;
		for (int i = height; 0 < i; --i) propagate((l+length) >> i), propagate((r+length-1) >> i);
		typeNode ret = Op.unitNode;
		size_t off = l;
		for(size_t idx = l+length; idx < 2*length && off < r; ){
			if(range[idx].second<=r && !Op.funcCheck(Op.funcNode(ret,Op.funcMerge(node[idx],lazy[idx],range[idx].second-range[idx].first)),var)) {
				ret = Op.funcNode(ret,Op.funcMerge(node[idx],lazy[idx],range[idx].second-range[idx].first));
				off = range[idx++].second;
				if(!(idx&1)) idx >>= 1;			
			}
			else{
				idx <<=1;
			}
		}
		return off;
	}
```

# 実用例
実際の使い方を見て覚えるのが良さそうです。

#### 普通に使うとき
- 非再起抽象化セグメント木  
	- https://atcoder.jp/contests/abc157/submissions/11343448
- 非再起抽象化遅延伝搬セグメント木 
	- https://atcoder.jp/contests/nikkei2019-final/submissions/11343285

#### 抽象化が嬉しい問題
- 1次関数
	- https://atcoder.jp/contests/arc008/submissions/11343644
- 行列
	- https://atcoder.jp/contests/ddcc2019-final/submissions/11344348

#### セグ木上の二分探索

- 非再起抽象化セグメント木  
	- https://atcoder.jp/contests/arc033/submissions/11344529
	- https://atcoder.jp/contests/abc130/submissions/10809757
	- https://atcoder.jp/contests/abc102/submissions/11343129  
- 非再起抽象化遅延伝搬セグメント木 
	- https://atcoder.jp/contests/abc130/submissions/10809794  
	- https://atcoder.jp/contests/abc102/submissions/11342964


## おわりに
記事中のコードは簡略化していたりするので、github側を参考にしてください。  

- 非再起抽象化セグメント木  
	- https://github.com/ningenMe/compro-library/blob/master/SegmentTree.cpp  
- 非再起抽象化遅延伝搬セグメント木 
	- https://github.com/ningenMe/compro-library/blob/master/LazySegmentTree.cpp  


