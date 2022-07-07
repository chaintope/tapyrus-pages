---
layout: single
permalink: /setup/dev-docker
title: "Tapyrus Coreノード devモード起動方法（Docker版）"
---

この記事ではDocker環境上に、devモードでTapyrus Coreノードを起動する方法を解説します。  
公式のドキュメントは[こちら](https://github.com/chaintope/tapyrus-core/blob/master/doc/docker_image.md#dev-mode){:target="_blank"}です。  

また、本記事ではコマンドの実行にターミナルアプリケーション使用します。  
記載されたコマンドを順に実行することでdevモードでTapyrusノード起動が完了します。  


Docker Hub上に公開された[tapyrus/tapyrusd](https://hub.docker.com/r/tapyrus/tapyrusd){:target="_blank"}の[v0.5.1](https://hub.docker.com/layers/tapyrusd/tapyrus/tapyrusd/v0.5.1/images/sha256-0e25122fe7805ecc3a4545862befe3e0a9ec60ad211b94afa8d07d5ac2a5198c?context=explore){:target="_blank"}を使用します。  


## 前提 {#prerequisites}
本記事ではDockerがインストール済みの前提で解説を行います。  
また、本記事では鍵導出のため、rubyライブラリの[tapyrusrb](https://github.com/chaintope/tapyrusrb){:target="_blank"}を用います。
事前にruby 3.0をインストールして置いてください。  
`tapyrus.conf`ファイルはデフォルトでdevモード用のものがコンテナ内に生成されるため、作成は不要です。

## 鍵導出 {#derive-key}

鍵導出の方法は様々ありますが、本記事では[tapyruseb](https://github.com/chaintope/tapyrusrb){:target="_blank"}ライブラリを用います。  
以下のコマンドでtapyrusebのgemをインストールします。
```
$ gem install tapyrus
```

[Github上の鍵導出用Rubyファイル(generate_key_pair.rb)](https://github.com/chaintope/tapyrus-pages/scripts/generate_key_pair.rb){:target="_blank"}をダウンロードしてください。
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

`tapyrus/tapyrusd:v0.5.1`のイメージを指定し、genesisブロックの生成を行ないます。  
genesisブロックの生成には`tapyrus-genesis`コマンドを用います。
`-dev`でdevモードであることを指定し、控えておいた`<秘密鍵>`を`signblockprivatekey`に、`<公開鍵>`を`signblockpubkey`にオプションとして指定して以下のコマンドを実行します。
実行すると表示される文字列の値がgenesisブロックです。
genesisブロックの値は次に使用するため控えておいてください。
```
$ docker run tapyrus/tapyrusd:v0.5.1 tapyrus-genesis -dev -signblockpubkey=<公開鍵> -signblockprivatekey=<秘密鍵>
```

## Tapyrusノードを起動する {#run-tapyrusd}

Dockerコンテナの作成・起動を行います。  
コンテナ作成時に`-e`オプションを使用し`GENESIS_BLOCK_WITH_SIG`に先程控えておいてgenesisブロックの値をを指定します。
```
$ docker run -d --name 'tapyrus_node_dev' -e GENESIS_BLOCK_WITH_SIG='<genesisブロック>' tapyrus/tapyrusd:v0.5.1
```

上記のコマンドを実行し、ハッシュ値のコンテナIDが表示されると起動成功です。

コンテナ内で`tapyrus-cli`の`getblockchaininfo`コマンドを用いて、ブロックチェーンの情報を確認します。　　
```
$ docker exec tapyrus_node_dev tapyrus-cli -conf=/etc/tapyrus/tapyrus.conf getblockchaininfo
```

以下のようなブロックチェーンの情報を確認できればTapyrus Coreがdevモードで動作していることが確認できます。(詳細な数値は環境ごとに異なります)  
```javascript
{
  "chain": "1905960821",
  "mode": "dev",
  "blocks": 0,
  "headers": 0,
  "bestblockhash": "444670fdee18be68683c9c6f413f38de8d2471fd51c8cbf50cf6ac442af49d94",
  "mediantime": 1657067469,
  "verificationprogress": 1,
  "initialblockdownload": false,
  "size_on_disk": 298,
  "pruned": false,
  "aggregatePubkeys": [
    {
      "02030c6a9d43ab96e7440f549d4b0447b4444b44f0c0287bc78ef70d5295813fb4": 0
    }
  ],
  "warnings": ""
}
```

コンテナを停止する場合、以下のコマンドを実行します。
```
$ docker stop tapyrus_node_dev
```

以上でDocker環境でTapyrus Coreノードがdevモードで立ち上がりました。