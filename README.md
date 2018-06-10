# desk
Re:VIEWビルド用コンテナです。
Alpine Linuxをベースとしています。


## 利用方法
```
$ docker pull lrks/desk
$ docker run -v "/home/hoge/book/src/:/work" lrks/desk /bin/ash -c build.rb --proof --pdf4print --pdf4publish --epub --workdir=/work --margin=3mm --verbose
```
実際にはこれをラップした`template/make.sh`を通して使うことが多いはず。


## build.rbのオプション
### `--proof`
[prh](https://github.com/prh/prh)で校正を行う。
設定ファイルは、[techbooster.yml](https://github.com/prh/rules/blob/master/media/techbooster.yml)をそのまま利用。
また、 `src/working_temporary_directory/book-text` 以下に `review-textmaker` によるファイルが出力される。

### `--pdf4print` / `--margin=Xmm`
`--pdf4print`で印刷用PDF(honbun.pdf)を作成する。
`--margin=Xmm` (default:--margin=3mm) で塗り足しサイズを決める。
templateでは、B5サイズから上下左右に5mm大きく作っており、上限は`--margin=5mm`となる。
なお、これらに関わらず、Re:VIEW(+ LaTeX)のPDF(original.pdf)は作成される。
上記のパラメータは、これを印刷用に加工するか否かの設定となる。

### `---pdf4publish` / `--papersize=X`
`--pdf4publish`で電子版PDF(publish.pdf)を作成する。
これによって環境変数に`ONESIDE=1`が設定される。
`layout.tex.erb`から読めば印刷版と電子版で異なる組版ができる。
`src/cover.png`と`src/back.png`を配置すれば、それぞれ表紙と背表紙としたPDFが出力される。
また、`--papersize=X` (default:--papersize=b5`) は、その紙面サイズを決める。
`src/cover.png`と`src/back.png`を配置するサイズを決めるため、`documentclass`にそのまま渡される。

### `--epub`
EPUB(publish.epub)を作成する。
`src/cover.png`から電子書籍ストアの仕様に適合しそうな`epub-cover.png`が自動作成される。

### `--workdir=X` / `--strict` / `--verbose`
`--workdir=X`で`src/`を指定する。
`--strict`は、ある原稿ファイルのビルドでエラーが発生したときにそのファイルを外してビルドし直すか否かのフラグ。
設定するとstrictモードになって、再挑戦しない。
`--verbose`は、通常出力しないLaTeX処理系や各種ソフトウェアからのメッセージを出力するか否かのフラグ。
また、`src/working_temporary_directory/`の中身を整理せず、中間作成物をすべて残すか否かのフラグ。


## 開発方法
* Dockerが動くLinux環境があればいい
* GitHub Flowで開発していく
* `Dockerfile.yml` をいじると思う
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
* `template/make.sh`を使うと思う
  * `make build` (= `make`) したなら、`env CONTAINER_VERSION="debug" ./make.sh build --help`で実行できる

## Contribution
* fork して pull request してもらえたらと思います。
* SIGCOWWメンバーなど、既にリポジトリへのWrite権限があれば、forkせず直接ブランチを切ってもらっても構いません。


## License
本ソフトウェアは LGPL v2.1 で提供されています。
```
Copyright (c) 2017-2018 SIGCOWW.
```

本ソフトウェアのリポジトリには、下記ソフトウェアの一部または全部が含まれます。

### [Re:VIEW](https://github.com/kmuto/review)
GNU Lesser General Public License v2.1 ([COPYING](https://github.com/kmuto/review/blob/master/COPYING))
```
Copyright (c) 2006-2018 Minero Aoki, Kenshi Muto, Masayoshi Takahashi, Masanori Kado.
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
