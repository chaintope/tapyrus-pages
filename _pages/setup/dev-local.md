---
layout: single
permalink: /setup/dev-local
title: "Tapyrus Coreノード devモード起動方法（MacOS/Ubuntu版）"
---

この記事ではMacOS/Ubuntu環境上に、devモードでTapyrus Coreノードを起動する方法を解説します。
devモードとは開発やテストの際、ローカルでSigner Networkを用いずTapyrus Core単体でブロックの生成を行い、単一のTapyrusノードを実行するための開発用環境です。
公式のドキュメントは[こちら](https://github.com/chaintope/tapyrus-core/blob/master/doc/tapyrus/getting_started.md#how-to-start-tapyrus-in-dev-mode){:target="_blank"}です。  

また、本記事ではコマンドの実行にターミナルアプリケーション使用します。
記載されたコマンドを順に実行することでdevモードでTapyrusノード起動が完了します。

## 前提 {#prerequisites}

本記事では鍵導出のため、rubyライブラリの[tapyrusrb](https://github.com/chaintope/tapyrusrb){:target="_blank"}を用います。  
事前にruby 3.0をインストールして置いてください。
また、本記事ではTapyrusノードの環境構築方法については解説しません。
環境構築方法については、以下のそれぞれの記事の「ビルド」項目までを実行してください。
 - [Tapyrus Coreノード構築方法（macOS版）](https://site.tapyrus.chaintope.com/setup/osx)
 - [Tapyrus Coreノード構築方法（Ubuntu版）](https://site.tapyrus.chaintope.com/setup/ubuntu)


## データディレクトリ・設定ファイル作成 {#create-dir-conf}

ディレクトリ配下に、ブロックチェーンのデータを保存する`tapyrus-dev`ディレクトリを作成します。  
（Ubuntu環境）
```
$ mkdir ~/.tapyrus
```

（MacOS環境）
```
$ mkdir /Users/$(whoami)/Library/Application\ Support/Tapyrus
```

Tapyrusノードの設定を`tapyrus.conf`ファイルに記述します。  
以下のコマンドを実行し、`/etc/tapyrus/`ディレクトリ配下に`tapyrus.conf`ファイルが生成されます。  
（Ubuntu環境）
```
$ cat <<EOF >  ~/.tapyrus/tapyrus.conf
networkid=1905960821
dev=1
[dev]
server=1
keypool=1
discover=0
rpcuser=user
rpcpassword=pass
bind=127.0.0.1
rpcbind=0.0.0.0
rpcallowip=127.0.0.1
EOF
```

（MacOS環境）
```
$ cat <<EOF >  /Users/$(whoami)/Library/Application\ Support/Tapyrus/tapyrus.conf
networkid=1905960821
dev=1
[dev]
server=1
keypool=1
discover=0
rpcuser=user
rpcpassword=pass
bind=127.0.0.1
rpcbind=0.0.0.0
rpcallowip=127.0.0.1
EOF
```

## 鍵導出 {#derive-key}

鍵導出の方法は様々ありますが、本記事では[tapyruseb](https://github.com/chaintope/tapyrusrb){:target="_blank"}ライブラリを用います。  
以下のコマンドでtapyrusebのgemをインストールします。
```
$ gem install tapyrus
```

[Github上の鍵導出用Rubyファイル(generate_key_pair.rb)](https://github.com/chaintope/tapyrus-pages/blob/master/scripts/generate_key_pair.rb){:target="_blank"}をダウンロードしてください。
ファイルには以下のようなコードが書かれています。  

```ruby
require 'tapyrus'

Tapyrus.chain_params = :dev
key_pair = Tapyrus::Key.generate
puts "秘密鍵(WIF): #{key_pair.to_wif}"
puts "公開鍵： #{key_pair.pubkey}"
```

以下のようにファイルの実行、もしくはRubyの対話モード(irb)で上記コードを一行づつ実行してください。
```
$ ruby generate_key_pair.rb
```

実行すると以下のような出力が表示されます。
 `<秘密鍵>`, `<公開鍵>`に表示されている文字列の値を控えておきます。
```
秘密鍵(WIF): <秘密鍵>
公開鍵： <公開鍵>
```

また、将来的に`tapyrus-genesis`に`createkey`コマンドの実装を予定しており、上記のような手順を用いずにコマンドラインからの鍵導出が可能になります。


## genesisブロックの生成 {#generate-genesis-block}
`dev`モードで動作するためのチェーンのgenesisブロックの生成を行ないます。  
genesisブロックの生成には`tapyrus-genesis`コマンドを用います。
`-dev`でdevモードであることを指定し、控えておいた`<秘密鍵>`を`signblockprivatekey`に、`<公開鍵>`を`signblockpubkey`にオプションとして指定して以下のコマンドを実行します。
実行すると表示される文字列の値がgenesisブロックです。
genesisブロックの値は次に使用するため控えておいてください。
```
$ tapyrus-genesis -dev -signblockprivatekey=<秘密鍵> -signblockpubkey=<公開鍵> 
```

Tapyrus Coreのデフォルトディレクトリ配下の`genesis.1905960821`ファイルにgenesisブロックの値を書き込みます。
（Ubuntu環境）
```
$ echo <genesisブロックの値> > ~/.tapyrus/genesis.1905960821
```
（MacOS環境）
```
$ echo <genesisブロックの値> >  /Users/$(whoami)/Library/Application\ Support/Tapyrus/genesis.1905960821
```


## Tapyrusノードを起動する {#run-tapyrusd}

以下のコマンドを実行し、Tapyrus Coreを起動します。  
```
$  tapyrusd
```

`tapyrus-cli`の`getblockchaininfo`コマンドを用いて、ブロックチェーンの情報を確認します。  
```
$ tapyrus-cli getblockchaininfo
```

以下のようなブロックチェーンの情報を確認できればTapyrus Coreがdevモードで動作していることが確認できます。(詳細な数値は環境ごとに異なります)  
```javascript
{
  "chain": "1905960821",
  "mode": "dev",
  "blocks": 0,
  "headers": 0,
  "bestblockhash": "bffcb5d2c676dfcedf08ec2837d91f45db31430bc8f2c77952516ceafa858f55",
  "mediantime": 1656999523,
  "verificationprogress": 1,
  "initialblockdownload": false,
  "size_on_disk": 298,
  "pruned": false,
  "aggregatePubkeys": [
    {
      "0311a61fba9dbc48e91fe9b14bf8507733adf99688b7731bac1cbaf1b3c170b645": 0
    }
  ],
  "warnings": ""
}
```

## ブロックの生成 {#generate-block}
devモードではSignerノードが存在しないため、コマンドを実行しブロックの生成を行なう必要があります。
まずはブロック生成に用いるアドレスを生成します。
```
$ tapyrus-cli  getnewaddress
```

ブロックの生成には`generatetoaddress`コマンドを用います。  
引数として、`生成するブロックの数` `ブロック報酬を受け取るアドレス`、`genesisブロックの生成に使用した秘密鍵`を指定します。
```
$ tapyrus-cli generatetoaddress 1 <ブロック報酬を受け取るアドレス> <genesisブロックの生成に使用した秘密鍵>
```

以下のような配列で文字列のブロックハッシュが表示されるとブロックの生成は成功です。(詳細な値は実行した環境ごとに異なります)
```
[
  "95879e38c65c010b7cf9d734dbcdffd8ec59db33cdd943ab627dc9789686e6b9"
]
```

## ノードの停止 {#stop-tapyrusd}
ノードを停止する場合、以下のコマンドを実行します。  
```
$ tapyrus-cli stop
```

以上でMacOS & Ubuntu環境でTapyrus Coreノードがdevモードで立ち上がりました。  


