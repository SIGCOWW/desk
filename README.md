# desk
Alpine LinuxをベースとしたRe:VIEWビルド用のコンテナ。
https://github.com/SIGCOWW/template と組み合わせて使う。


## 使い方
こんな感じ。
```
$ docker pull lrks/desk
$ docker run -v "/home/hoge/book/src/:/work" lrks/desk /bin/ash -c build.rb --proof --pdf4print --pdf4publish --epub --workdir=/work --margin=3mm --verbose
```
templateのリポジトリにこれをラップする`make.sh`が入っている。


## build.rbのオプション
### `--proof`
[prh](https://github.com/prh/prh)で校正を行う。
設定ファイルは、[techbooster.yml](https://github.com/prh/rules/blob/master/media/techbooster.yml)をそのまま利用。

### `--pdf4print` / `--margin=Xmm`
`--pdf4print`で印刷用PDFを作成する。
`--margin=Xmm` (default:--margin=3mm) で塗り足しサイズを決める。
templateでは、B5サイズから上下左右に5mm大きく作っており、上限は`--margin=5mm`となる。

なお、これらに関わらず、Re:VIEW(+ LaTeX)のPDFは作成される。
上記のパラメータは、これを印刷用に加工するか否かの設定となる。

### `---pdf4publish` / `--papersize=X`
`--pdf4publish`で電子版PDFを作成する。
これによって環境変数に`ONESIDE=1`が設定される。
`layout.tex.erb`から読めば印刷版と電子版で異なる組版ができる。
`src/cover.png`と`src/back.png`を配置すれば、それぞれ表紙と背表紙としたPDFが出力される。

また、`--papersize=X` (default:--papersize=b5`) は、その紙面サイズを決める。
`src/cover.png`と`src/back.png`を配置するサイズを決めるため、`documentclass`にそのまま渡される。

### `--epub`
EPUBを作成する。
`src/cover.png`から電子書籍ストアの仕様に適合しそうな`epub-cover.png`が自動作成される。

### `--workdir=X` / `--strict` / `--verbose`
`--workdir=X`で`src/`を指定する。

`--strict`は、ある原稿ファイルのビルドでエラーが発生したときにそのファイルを外してビルドし直すか否かのフラグ。
設定するとstrictモードになって、再挑戦しない。

`--verbose`は、通常出力しないLaTeX処理系や各種ソフトウェアからのメッセージを出力するか否かのフラグ。
また、`src/working_temporary_directory/`の中身を整理せず、中間作成物をすべて残すか否かのフラグ。
