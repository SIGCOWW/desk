# template
同人誌のテンプレート。
サンプル文章として、deskとRe:VIEW文法の紹介が入っている。


## 利用方法
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
ただ、ビルドは下記のような処理が中止なので、手動で叩けば動きそうではある。
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
     ├─ publish.pdf .... 電子書籍PDF
     └─ publish.epub ... 電子書籍EPUB
```

## `config.yml`
本来のRe:VIEWとは意味を変えている、また独自に追加した項目がある。
例えば、

* `oth` ... Webサイトのアドレス
* `edt` ... 連絡先メールアドレス
* `feedback` ... 連絡フォーム(感想)
* `msg` ... なんかメッセージ

がある。いずれもコメントアウトすれば出力されない。


## 注意
### こんなファイル・ディレクトリは作らない
* src/working_temporary_directory/
* .temporary.diff
* 移動・削除される可能性がある

### 画像
* 入稿版は白黒に変換される
* ラスタ画像の解像度は 350ppi 以上を推奨
  * B5判いっぱいに貼り付ける場合は「2508px x 3541px」以上
  * 本文領域いっぱいに貼り付ける場合は、「1600px x 2977px」程度

### 文字コードはUTF-8
* そもそも、それ以外だとGitHubで見たときに文字化けしそうな気もする
