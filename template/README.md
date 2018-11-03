# SIGCOWW Template
同人誌のテンプレート。
サンプル文章として、deskとRe:VIEW文法の紹介が入っている。



## 使い方
deskのDockerコンテナが実行できる環境が必要になる。

### Linux
```
$ ./make.sh install kakuyo
$ vim src/articles/kakuyo/kakuyo.re
$ cp ~/dokokano/dir/hoge.png src/article/kakuyo/images/
$ ./make.sh build --help
$ ./make.sh build # src/working_temporary_directory/ にPDFができる
$ git add -A
$ git commit -m "TEST" # or git commit -m "[ci skip] TEST"
$ git push origin master
```
`build`の引数は、desk内の`build.rb`に渡される。

### その他
その他のOSは未検証。
ただ、ビルドは下記のような処理が中心なので、手動で叩けば動きそうではある。
```
$ docker pull (.circleci/config.yml の images)
$ docker run -v "(srcのディレクトリ):/work" (いまpullしたイメージ) /bin/ash -c (.circleci/config.yml の run)
```
なお、WindowsのDocker Toolboxなら `(srcのディレクトリ)` を `C:\Users` 配下にすると楽らしい。



## ディレクトリ構成
```
src/
├─ articles/ ..... 原稿ディレクトリ
│   └─ hoge/
│        ├─ hoge.rb ... 原稿本体
│        └─ images/ ... 画像ディレクトリ
├─ cover.png ..... 表紙画像
├─ back.png ...... 背表紙画像
│
└─ working_temporary_directory/ ..... 成果物ディレクトリ(Git管理外)
     ├─ origin.pdf ..... Re:VIEWによる出力
     ├─ honbun.pdf ..... 入稿用PDF
     ├─ publish-row.pdf .... 電子書籍PDF（Re:VIEW出力そのまま）
     ├─ publish-ebook.pdf .... 電子書籍PDF（publish-raw.pdfをghostscriptで最適化…のはずだがテキスト選択に難がある）
     └─ publish.epub ... 電子書籍EPUB
```
これを作るのは`tree`コマンドが便利。



## `config.yml` について
本来のRe:VIEWとは意味を変えている、また独自に追加した項目がある。
例えば、

* `oth` ... Webサイトのアドレス
* `edt` ... 連絡先メールアドレス
* `feedback` ... 連絡フォーム(感想)
* `msg` ... なんかメッセージ

* `container_version` ... deskのバージョン
* `layout_hash` ... layout.tex.erb のMD5ハッシュ
* `sty_hash` ... sigcoww.sty のMD5ハッシュ
* `latextitle` ... 扉ページとして挿入するLaTeXコマンド
* `download` ... ダウンロード用URL。`%s`には乱数が入る。

がある。いずれも省略可能。



## 注意
### こんなファイル・ディレクトリは作らない
* working_temporary_directory/
* .temporary.diff
* 移動・削除される可能性がある

### 画像
* 入稿版は白黒に変換される
* ラスタ画像の解像度は 350ppi 以上を推奨
  * B5判いっぱいに貼り付ける場合は「2508px x 3541px」以上
  * 本文領域いっぱいに貼り付ける場合は、「1600px x 2977px」程度

### 文字コードはUTF-8
* GitHubで管理するならそうなっているはずだが一応



## ライセンス
本ディレクトリ以下は、[Beerwareライセンス](https://en.wikipedia.org/wiki/Beerware)のもとで提供されます。
```
/*
* ----------------------------------------------------------------------------
* "THE BEER-WARE LICENSE" (Revision 42):
* sigcoww@sigcoww.org wrote this file. As long as you retain this notice you
* can do whatever you want with this stuff. If we meet some day, and you think
* this stuff is worth it, you can buy me a beer in return            SIGCOWW
* ----------------------------------------------------------------------------
*/
```

本ディレクトリ以下には、下記ソフトウェアの一部が含まれます。

### [template files for Re:VIEW](https://github.com/kmuto/review/tree/master/templates)
The MIT License ([LICENSE](https://github.com/kmuto/review/blob/master/templates/LICENSE))
```
Copyright (c) 2006-2016 Minero Aoki, Kenshi Muto, Masayoshi Takahashi, Masanori Kado.
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
