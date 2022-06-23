---
layout: single
permalink: /setup/docker
title: "Tapyrus Coreノード構築方法（Docker版）"
---

この記事ではDockerを用いたTapyrus Coreのノード構築方法を解説します。  
公式のドキュメントは[こちら](https://github.com/oshikawatkm/tapyrus-core/blob/master/doc/docker_image.md){:target="_blank"}です。

本記事では、Tapyrus Coreのセットアップ方法と、Chaintopeが提供するTapyrusのテストネット（networkid 1939510133）に参加する方法を解説しています。 

Docker Hub上に公開された[tapyrus/tapyrusd](https://hub.docker.com/r/tapyrus/tapyrusd){:target="_blank"}の[v0.5.1](https://hub.docker.com/layers/tapyrusd/tapyrus/tapyrusd/v0.5.1/images/sha256-0e25122fe7805ecc3a4545862befe3e0a9ec60ad211b94afa8d07d5ac2a5198c?context=explore){:target="_blank"}を使用します。

また、本記事ではDockerのインストール手順の説明は省略しているため、Dockerがインストール済みの前提で解説を行います。

## 準備

Tapyrusノードの設定ファイルを作成します。tapyrusdでは`tapyrus.conf`ファイルに設定を記述します。   
以下のコマンドで`tapyrus.conf`ファイルの作成と設定情報の記述を行います。  
```shell
$ cat << EOS > tapyrus.conf
networkid=1939510133
txindex=1
server=1
rest=1
rpcuser=rpcuser
rpcpassword=rpcpassword
rpcbind=0.0.0.0
rpcallowip=127.0.0.1
addseeder=static-seed.tapyrus.dev.chaintope.com
EOS
```

## コンテナ作成・起動

`tapyrus/tapyrusd:v0.5.1`のイメージを指定し、Dockerコンテナの作成・起動を行います。  
コンテナ作成時に`-e`オプションを使用し`GENESIS_BLOCK_WITH_SIG`にgenesisブロック情報を設定します。  
```
$ docker run -d --name 'tapyrus_node_testnet' -v $PWD/tapyrus.conf:/etc/tapyrus/tapyrus.conf -e GENESIS_BLOCK_WITH_SIG='01000000000000000000000000000000000000000000000000000000000000000000000044cc181bd0e95c5b999a13d1fc0d193fa8223af97511ad2098217555a841b3518f18ec2536f0bb9d6d4834fcc712e9563840fe9f089db9e8fe890bffb82165849f52ba5e01210366262690cbdf648132ce0c088962c6361112582364ede120f3780ab73438fc4b402b1ed9996920f57a425f6f9797557c0e73d0c9fbafdebcaa796b136e0946ffa98d928f8130b6a572f83da39530b13784eeb7007465b673aa95091619e7ee208501010000000100000000000000000000000000000000000000000000000000000000000000000000000000ffffffff0100f2052a010000002776a92231415132437447336a686f37385372457a4b6533766636647863456b4a74356e7a4188ac00000000' tapyrus/tapyrusd:v0.5.1
```

上記のコマンドを実行し、ハッシュ値のコンテナIDが表示されると起動成功です。

コンテナ内で`tapyrus-cli`の`getblockchaininfo`コマンドを用いて、ブロックチェーンの情報を確認します。　　
```
$ docker exec tapyrus_node_testnet tapyrus-cli -conf=/etc/tapyrus/tapyrus.conf getblockchaininfo
```

以下のようなブロックチェーンの情報を確認できればTapyrus Coreが動作していることが確認できます。(詳細な数値は実行したタイミングごとに異なります)
```javascript
{
  "chain": "1939510133",
  "mode": "prod",
  "blocks": 144,
  "headers": 20000,
  "bestblockhash": "568d7b74cccf162dd8c6aa143a4701330bc6e2f7cf91cc05a2ddc31d3c515246",
  "mediantime": 1589489965,
  "verificationprogress": 1,
  "initialblockdownload": true,
  "size_on_disk": 44809,
  "pruned": false,
  "aggregatePubkeys": [
    {
      "0366262690cbdf648132ce0c088962c6361112582364ede120f3780ab73438fc4b": 0
    }
  ],
  "warnings": ""
}
```

コンテナを停止する場合、以下のコマンドを実行します。
```
$ docker stop tapyrus_node_testnet
```

以上でDocker環境でTapyrus Coreノードが立ち上がり、ChaintopeのTapyrusテストネットと接続ができました。