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
deskは、@<tt>{src/layouts/}にある@<tt>{*.rb}ファイルを@<tt>{src/}へ展開しているため、@<tt>{src/layouts/review-ext.rb}を書き換えておくと、自由に拡張できます。

なお、拡張の仕様についてはRe:VIEWのドキュメント@<fn>{doc}があります。
実装の際は、@<tt>{LATEXBuilder}、@<tt>{HTMLBuilder}、@<tt>{PLAINTEXTBuilder}向きの定義がないとdeskが落ちるので注意が必要です。
//footnote[doc][@<href>{https://github.com/kmuto/review/blob/master/doc/format.ja.md#%E3%81%9D%E3%81%AE%E4%BB%96%E3%81%AE%E6%96%87%E6%B3%95}]

== デザインを変えたい
LaTeXの場合は、原稿リポジトリの@<tt>{src/layouts/layout.tex.erb}および@<tt>{src/layouts/sigcoww.sty}をいじります。
HTMLの場合は、@<tt>{src/layouts/style.css}をいじります。

== 「第○記事」という表記を変えたい
@<tt>{src/layouts/locale.yml}を作成します。
@<tt>{locale.yml}の仕様については、Re:VIEWのドキュメント@<fn>{docl}があります。
//footnote[docl][@<href>{https://github.com/kmuto/review/blob/master/doc/format.ja.md#%E5%9B%BD%E9%9A%9B%E5%8C%96i18n}]


== あのパッケージが使いたい
Re:VIEW拡張や数式の中で、パッケージを使いたい場合は@<tt>{src/layouts/layout.tex.erb}で@<tt>{\usepackage{\}}します。
ただ、そもそも@<tt>{.sty}がdeskのコンテナに存在しない場合は使えません。

そこで、どこかから@<tt>{.sty}を入手して、LaTeXから見えるような場所へ配置します。
具体的には、@<tt>{src/sty/}ディレクトリを作成して、その中へ突っ込めば読めるはずです。

なお、パッケージがインストールされているか否か、またあるファイルがどのパッケージに含まれるかは、desk内のシェル（ash）から@<tt>{kpsewhich}や@<tt>{tlmgr info}を実行すると分かります。


== 校正について
deskでは@<tt>{prh}による文章校正を行います。
なお、ここに出力されたからといって、必ずしも修正が必要なわけではありません。
あくまで参考としてご利用ください。

また、deskでは画像の解像度チェックもはじめました。
「@<tt>{//image}と@<tt>{scale=}で指定したラスタ画像(JPEG/PNG)」を、「@<tt>{紙幅-20mm}の領域に350dpiで出力する」際を想定し、画像が荒くなってしまう場合に警告します。
この警告が出た場合、画像形式をベクタ画像(PDF)にする、画像をレンダリングし直す、@<tt>{scale=}を下げるといった対応をおすすめします。
ここで、@<kusodeka>{単に画像を拡大するのは不適切}です。
やむを得ない場合、せめて超解像処理を施すべきでしょう。

なお、先ほどと同様ですが、ここに出力されたからといって必ずしも修正が必要なわけではありません。
実際に画像を出力する領域が、ここで想定しているよりも小さいという場合があるからです。
そのため、少し@<tt>{scale=}を下げるだけで解消するような場合は、無視しても大丈夫でしょう。

さらに、不適切な画像フォーマットの利用についても検出するようにしました。
具体的には、「写真でない画像（イラスト・ポンチ絵・グラフ）がJPEGで表現されている」場合に警告します。
こうした画像のフォーマットにJPEGを用いると、劣化が目立つためです。
改めて作図ツールなどからPNGやPDFで出力し直すことをおすすめします。
ここで、
@<kusodeka>{単にJPEGから変換するのは無意味}
です。
あと本当は写真なのに「写真ではない」と判定されたらごめんなさい。

//profile[机の上の次郎]{
著者名を変えてみました。
//}

//eyecatch[mid]{
この中は{\LaTeX}の世界
//}
