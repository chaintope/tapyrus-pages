---
layout: single
permalink: /setup/ubuntu
title: "Tapyrus Coreノード構築方法（Ubuntu版）"
---

この記事ではUbuntu 20.04 LTS環境でのTapyrus Coreのノード構築方法を解説します。  
公式のドキュメントは[こちら](https://github.com/chaintope/tapyrus-core/blob/master/doc/build-unix.md){:target="_blank"}です。

本記事では、Tapyrus Coreのセットアップ方法と、Chaintopeが提供するTapyrusのテストネット（networkid 1939510133）に参加する方法を解説しています。 

また、本記事ではコマンドの実行にターミナルアプリケーション使用します。  
記載されたコマンドを順に実行することでノードの構築が完了します。  


### 依存関係のインストール

依存ライブラリをインストールには以下のコマンドを実行します。  
依存ライブラリ情報は[こちら](https://github.com/chaintope/tapyrus-core/blob/master/doc/dependencies.md){:target="_blank"}で確認できます。
```
$ sudo apt-get install build-essential libtool autotools-dev automake pkg-config libevent-dev bsdmainutils python3 libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev
```

## ビルド

[tapyrus-core](https://github.com/chaintope/tapyrus-core){:target="_blank"}のリポジトリをcloneします。  
cloneの際、[secp256k1](https://github.com/chaintope/secp256k1){:target="_blank"}サブモジュールを同時にインストールするように、`--recursive`オプションを追加した状態で実行します。
```
$ git clone --recursive https://github.com/chaintope/tapyrus-core
```


Walletのデータベースとして使用するBerkeley DB 4.8をインストールします。  
tapyrus-coreのcontribディレクトリ配下に用意された[インストール用のスクリプト](https://github.com/chaintope/tapyrus-core/blob/master/contrib/install_db4.sh){:target="_blank"}を実行します。
```
$ cd tapyrus-core
$ ./contrib/install_db4.sh `pwd`
```

以下のコマンドでビルドを実行します。
```
$ ./autogen.sh
$ export BDB_PREFIX="/home/$(whoami)/tapyrus-core/db4"
$ ./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include"
$ make
```

エラーが表示されなければビルドは完了です。

## Tapyrusノードを起動する


Tapyrusノードを起動する前に設定を行います。設定は`tapyrus.conf`ファイルに記述します。  
Ubuntuではホームディレクトリ配下に`.tapyrus`ディレクトリを作成し、その配下に`tapyrus.conf`ファイルを作成、編集します。
```
$ mkdir ~/.tapyrus
$ vim ~/.tapyrus/tapyrus.conf
```

テストネット用の設定を`tapyrus.conf`内に書き込みます。
```
networkid=1939510133
txindex=1
server=1
rest=1
rpcuser=user
rpcpassword=pass
rpcbind=0.0.0.0
rpcallowip=127.0.0.1
addseeder=static-seed.tapyrus.dev.chaintope.com
fallbackfee=0.0002
```

`.tapyrus`ディレクトリ内にgenesisブロック作成します。
```
$ vim ~/.tapyrus/genesis.1939510133
```

`genesis.1939510133`内に以下のテストネットのgenesisブロックを書き込みます。
```
01000000000000000000000000000000000000000000000000000000000000000000000044cc181bd0e95c5b999a13d1fc0d193fa8223af97511ad2098217555a841b3518f18ec2536f0bb9d6d4834fcc712e9563840fe9f089db9e8fe890bffb82165849f52ba5e01210366262690cbdf648132ce0c088962c6361112582364ede120f3780ab73438fc4b402b1ed9996920f57a425f6f9797557c0e73d0c9fbafdebcaa796b136e0946ffa98d928f8130b6a572f83da39530b13784eeb7007465b673aa95091619e7ee208501010000000100000000000000000000000000000000000000000000000000000000000000000000000000ffffffff0100f2052a010000002776a92231415132437447336a686f37385372457a4b6533766636647863456b4a74356e7a4188ac00000000
```

Tapyrus Coreをデーモンで起動します。
```
$ ./src/tapyrusd -daemon 
```

`tapyrus-cli`の`getblockchaininfo`コマンドを用いて、ブロックチェーンの情報を確認します。
```
$ ./src/tapyrus-cli getblockchaininfo
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

ノードを停止する場合、以下のコマンドを実行します。
```
$ ./src/tapyrus-cli stop
```

以上でUbuntu20.04LTS環境でTapyrus Coreノードが立ち上がり、ChaintopeのTapyrusテストネットと接続ができました。
