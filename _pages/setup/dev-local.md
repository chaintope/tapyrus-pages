---
layout: single
permalink: /setup/dev-local
title: "Tapyrus Coreノード devモード起動方法（MacOS/Ubuntu版）"
---

この記事ではMacOS/Ubuntu環境上に、devモードでTapyrus Coreノードを起動する方法を解説します。  
公式のドキュメントは[こちら](https://github.com/chaintope/tapyrus-core/blob/master/doc/tapyrus/getting_started.md#how-to-start-tapyrus-in-dev-mode){:target="_blank"}です。  

また、本記事ではコマンドの実行にターミナルアプリケーション使用します。  
記載されたコマンドを順に実行することでdevモードでTapyrusノード起動が完了します。  

## 前提

本記事では鍵導出のため、rubyライブラリの[tapyrusrb](https://github.com/chaintope/tapyrusrb){:target="_blank"}を用います。  
事前にruby 3.0をインストールして置いてください。  
また、本記事ではTapyrusノードの環境構築方法については解説しません。  
環境構築方法については、以下のそれぞれの記事の「ビルド」項目までを実行してください。
 - [Tapyrus Coreノード構築方法（macOS版）](https://site.tapyrus.chaintope.com/setup/osx)
 - [Tapyrus Coreノード構築方法（Ubuntu版）](https://site.tapyrus.chaintope.com/setup/ubuntu)


## データディレクトリ・設定ファイル作成

`/var/lib/`ディレクトリ配下に、ブロックチェーンのデータを保存する`tapyrus-dev`ディレクトリを作成します。  
```
$ sudo mkdir /var/lib/tapyrus-dev
```

Tapyrusノードの設定を`tapyrus.conf`ファイルに記述します。  
以下のコマンドを実行し、`/etc/tapyrus/`ディレクトリ配下に`tapyrus.conf`ファイルが生成されます。  
```
$ sudo bash -c 'cat <<EOF >  /etc/tapyrus/tapyrus.conf
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
EOF'
```

## 鍵導出

鍵導出の方法は様々ありますが、本記事では[tapyruseb](https://github.com/chaintope/tapyrusrb){:target="_blank"}ライブラリを用います。  
[Github上の鍵導出用Rubyファイル(generate_key_pair.rb)](https://github.com/chaintope/tapyrus-pages/scripts/generate_key_pair.rb){:target="_blank"}をダウンロードしてください。  
ファイルには以下のようなコードが書かれています。  

```ruby
require 'tapyrus'

Tapyrus.chain_params = :dev
key_pair = Tapyrus::Secp256k1::Ruby.generate_key
puts "秘密鍵(WIF): #{Tapyrus::Key.new(priv_key: key_pair.priv_key).to_wif}"
puts "公開鍵： #{key_pair.pubkey}"
```

以下のようにファイルの実行、もしくはRubyの対話モード(irb)で上記コードを一行づつ実行してください。  
```
$ ruby generate_key_pair.rb
```

実行すると以下のような出力が表示されます。  
 `<秘密鍵>`, `<公開鍵>`に表示されている文字列の値を控えておきます。  
```
Use key_type parameter instead of compressed. compressed parameter removed in the future.
秘密鍵(WIF): <秘密鍵>
公開鍵： <公開鍵>
```

また、将来的に`tapyrus-genesis`に`createkey`コマンドの実装を予定しており、上記のような手順を用いずにコマンドラインからの鍵導出が可能になります。  


## genesisブロックの生成

genesisブロックの生成を行ないます。  
genesisブロックの生成には`tapyrus-genesis`コマンドを用います。  
`-dev`でdevモードであることを指定し、控えておいた`<秘密鍵>`を`signblockprivatekey`に、`<公開鍵>`を`signblockpubkey`にオプションとして指定して以下のコマンドを実行します。  
```
$ tapyrus-genesis -dev -signblockprivatekey=<秘密鍵> -signblockpubkey=<公開鍵> 
```

`/var/lib/tapyrus-dev`ディレクトリ配下の`genesis.1905960821`ファイルにgenesisブロック情報を書き込みます。  
```
$ sudo vim /var/lib/tapyrus-dev/genesis.1905960821
```

## Tapyrusノードを起動する

以下のコマンドを実行し、Tapyrus Coreを起動します。  
```
$ sudo tapyrusd -datadir=/var/lib/tapyrus-dev -conf=/etc/tapyrus/tapyrus.conf
```

`tapyrus-cli`の`getblockchaininfo`コマンドを用いて、ブロックチェーンの情報を確認します。  
```
$ tapyrus-cli -datadir=/var/lib/tapyrus-dev -conf=/etc/tapyrus/tapyrus.conf getblockchaininfo
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

ノードを停止する場合、以下のコマンドを実行します。  
```
$ tapyrus-cli -conf=/etc/tapyrus/tapyrus.conf stop
```

以上でMacOS & Ubuntu環境でTapyrus Coreノードがdevモードで立ち上がりました。  