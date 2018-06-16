= desk
@<author>{机上 次郎}
//lead{
deskを使う上で役立ちそうな情報を載せます。
続きはWebで。
@<href>{https://github.com/SIGCOWW/desk}
//}

== deskとは
Re:VIEWを用いてPDF/EPUBを吐くDockerコンテナとその周辺ツールの総称です。
画像の最適化機能のほか、便利なRe:VIEW拡張を備えています。

== こんなときどうする集
=== Re:VIEW拡張を追加したい
deskでは、@<tt>{docker/extensions/}内のファイルを原稿リポジトリの@<tt>{src/}へ展開します。
ここには、@<tt>{review-ext.rb}というファイルが含まれ、これをRe:VIEWが読み込むことで拡張が機能します。
deskは、すでに存在するファイルは上書きしないため、この@<tt>{review-ext.rb}をお好みで書き換えて配置しておくことで、拡張を自由に制御できます。

なお、拡張の仕様についてはRe:VIEWのドキュメント@<fn>{doc}があります。
実装の際は、@<tt>{LATEXBuilder}、@<tt>{HTMLBuilder}、@<tt>{PLAINTEXTBuilder}向きの定義がないとdeskが落ちるので注意が必要です。
//footnote[doc][@<href>{https://github.com/kmuto/review/blob/master/doc/format.ja.md#%E3%81%9D%E3%81%AE%E4%BB%96%E3%81%AE%E6%96%87%E6%B3%95}]

== デザインを変えたい
LaTeXの場合は、原稿リポジトリの@<tt>{src/layouts/layout.tex.erb}および@<tt>{src/layouts/sigcoww.sty}をいじります。
HTMLの場合は、@<tt>{src/layouts/style.css}をいじります。

== あのパッケージが使いたい
Re:VIEW拡張や数式の中で、パッケージを使いたい場合は@<tt>{src/layouts/layout.tex.erb}で@<tt>{\usepackage{\}}します。
ただ、そもそも@<tt>{.sty}がdeskのコンテナに存在しない場合は使えません。

そこで、どこかから@<tt>{.sty}を入手して、LaTeXから見えるような場所へ配置します。
具体的には、@<tt>{src/sty/}ディレクトリを作成して、その中へ突っ込めば読めるはずです。

なお、パッケージがインストールされているか否か、またあるファイルがどのパッケージに含まれるかは、desk内のシェル（ash）から@<tt>{kpsewhich}や@<tt>{tlmgr info}を実行すると分かります。

== その他
desk本体の要望・質問は、Issuesへ@<fn>{desk}。
組版に関する要望・質問は、templateのIssuesへ@<fn>{template}
どちらか分からなければ、それっぽいところへ。
//footnote[desk][@<href>{https://github.com/SIGCOWW/desk/issues}]
//footnote[template][@<href>{https://github.com/SIGCOWW/template/issues}]

//profile[机の上の次郎]{
著者名を変えてみました。
//}
