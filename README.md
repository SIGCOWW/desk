# desk
Re:VIEWビルド用コンテナです。
Alpine Linuxをベースとしています。



## 使い方
```
$ docker pull lrks/desk
$ docker run -v "/home/hoge/book/src/:/work" lrks/desk /bin/ash -c \
      build.rb --proof --pdf4print --pdf4publish --epub --workdir=/work --margin=3mm --verbose
```
実際にはこれをラップした`template/make.sh`を通して使うことが多いはず。



## build.rbのオプション
* `--proof`
  * [prh](https://github.com/prh/prh)で校正を行う
  * 設定ファイルは[techbooster.yml](https://github.com/prh/rules/blob/master/media/techbooster.yml)を利用
  * prhとは別に、`working_temporary_directory/book-text/` へ `review-textmaker` によるファイルを出力する

* `--pdf4print` / `--margin=Xmm`
  * `--pdf4print`で印刷用PDF(honbun.pdf)を作成する
    * [SIGCOWW templete](https://github.com/SIGCOWW/desk/tree/master/template)の場合、本来よりも上下左右が5mm大きなB5ファイル(origin.pdf)を作成する
    * なお、この設定に関わらずorigin.pdfは必ず作成する
	* 上記パラメータは、これを印刷用に加工するか否かの設定となる。
  * `--margin=Xmm` (default:--margin=3mm) で塗り足しサイズを決める
    * origin.pdfを削って、上下左右がXmm大きなB5ファイルを出力する

* `---pdf4publish` / `--papersize=X`
  * `--pdf4publish`で電子版PDF(publish.pdf)を作成する
    * これによって環境変数に`ONESIDE=1`が設定される
      * `layout.tex.erb`から読めば印刷版と電子版で異なる組版ができる
    * `src/cover.png`と`src/back.png`を配置すれば、それぞれ表紙と背表紙としたPDFが出力される
  * `--papersize=X` (default:--papersize=b5`) は、その紙面サイズを決める
    * `src/cover.png`と`src/back.png`を配置するサイズを決めるため、`documentclass`にそのまま渡される

* `--epub`
  * EPUB(publish.epub)を作成する
  * `src/cover.png`から電子書籍ストアの仕様に適合しそうな`epub-cover.png`を作成する

* `--workdir=X` / `--strict` / `--verbose`
  * `--workdir=X`で`src/`を指定する。
  * `--strict`は、ある原稿ファイルでビルドエラーが発生した際の挙動を変えるフラグ
    * デフォルトでは、そのファイルを外して再度ビルドを試みる
    * 設定するとstrictモードになって、再挑戦しない
  * `--verbose`は、通常出力しないLaTeX処理系や各種ソフトウェアからのメッセージを出力するか否かのフラグ
    * 設定すると、`working_temporary_directory/`の中身を整理せず、中間作成物をすべて残す



## License
本ソフトウェアは LGPL v2.1 で提供されています。
```
Copyright (c) 2017-2018 SIGCOWW.
```
ただし、 `templete/` ディレクトリ以下は、別のライセンスが適用されています。

また、本ソフトウェアのリポジトリには、下記ソフトウェアの一部または全部が含まれます。

### [Re:VIEW](https://github.com/kmuto/review)
GNU Lesser General Public License v2.1 ([COPYING](https://github.com/kmuto/review/blob/master/COPYING))
```
Copyright (c) 2006-2018 Minero Aoki, Kenshi Muto, Masayoshi Takahashi, Masanori Kado.
```

### [template files for Re:VIEW](https://github.com/kmuto/review/tree/master/templates)
The MIT License ([LICENSE](https://github.com/kmuto/review/blob/master/templates/LICENSE))
```
Copyright (c) 2006-2016 Minero Aoki, Kenshi Muto, Masayoshi Takahashi, Masanori Kado.
```

### [jumoline.sty](http://www.para.media.kyoto-u.ac.jp/latex/)
The LaTeX Project Public License ([lppl.txt](https://www.latex-project.org/lppl.txt))
```
Copyright (C) 1999-2001  Hiroshi Nakashima
        (Toyohashi Univ. of Tech.)
```

### [ReVIEW-Template](https://github.com/TechBooster/ReVIEW-Template)
The MIT License
```
Copyright 2017 TechBooster

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

### [jsclasses](https://github.com/texjporg/jsclasses)
BSD 2-Clause "Simplified" License ([LICENSE](https://github.com/texjporg/jsclasses/blob/master/LICENSE))
```
pLaTeX2ε新ドキュメントクラス（日本語 TeX 開発コミュニティ版）
原作者：奥村晴彦 <okumura@okumuralab.org>

Copyright 1993-2016
The LaTeX3 Project and any individual authors listed elsewhere
in this file.

Copyright 1995-1999 ASCII Corporation.
Copyright 1999-2016 Haruhiko Okumura
Copyright 2016-2018 Japanese TeX Development Community
```



## Contribution
fork して pull request してもらえたらと思います。
SIGCOWWメンバーなど、既にリポジトリへのWrite権限があれば、forkせず直接ブランチを切ってもらっても構いません。

開発手順は以下のとおりです。

### 開発環境
* Dockerが動くLinux環境があればいい
* GitHub Flowで開発していく

### 仕様紹介
#### `Dockerfile.yml` について
* デバッグ用とリリース用でDockerfileを切り替えるためにymlでラップした

* `make build` すると `docker/Dockerfile` が作成されて、Dockerイメージができる
* `make release` するとRUNをチェインしたDockerfileでイメージを作る
  * どっちで作ったDockerfileをリポジトリにpushしても問題ない
    * 開発中は`make build`で作ったほうしかテストしない(単体テスト扱い)
    * 「リリース準備」とか言ったときに`make release`する(結合テスト扱い)
* `make run` するとコンテナ内でシェルを立ち上げる

* `Dockerfile.yml` に出てくるキーワードの意味
  * `env` ... 環境変数設定。`ENV` と同じ。Releaseの際はDockerfileの先頭にまとめて出力される。
  * `apk` ... パッケージインストール。`RUN apk add #{val}` を実行。Releaseの際はDockerfile先頭にまとめて出力。
  * `dev` ... 開発用パッケージインストール。`RUN apk add #{val}` を実行。Releaseの際はまとめて以下略、あと最後で`apk del`される。
  * `copy` ... ファイルコピー。`COPY #{val} /` を実行。Releaseの際はまとめ以下略。
  * `run` ... コマンド実行。`RUN #{val}` を実行
  * `rmrf` ... ファイル削除。`RUN find #{head} -iname #{name1} -o -iname #{name2} ... | grep -v /proc/ | xargs rm -rf` を実行

#### `template/make.sh` について
* Makefile のつもりで書いている
  * シェルスクリプトなのは、makeコマンドが存在しなくてもビルドできるようにするため
  * `/bin/sh` で動かすことを目指す
    * bashが入っていない環境でも動くことを期待
	* [ShellCheck](https://www.shellcheck.net/) で確認

* 動作
  * Dockerfileを`make build` (= `make`)で作ると、`lrks/desk:debug`というイメージができる
  * `env CONTAINER_VERSION="debug" ./make.sh build --help` とすると、そのイメージを使って原稿をビルドする

#### テスト
* 簡易でいい
* `env CONTAINER_VERSION="debug" ./make.sh build --proof --pdf4print --pdf4publish --epub --strict --verbose` な感じ
* ぱっと見でエラーが出ていない、かつ出力が想定どおりならOKでいい
* それで問題があったら自動テストを用意する

#### Tips
* `du -b ./* | sort -rn | numfmt --to=iec --suffix=B --padding=5 | head`
