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

「ビルド済みのバイナリの利用」と「ソースコードからのビルド」の2種類のセットアップ方法を解説します。

##  (インストール方法1) ビルド済みのバイナリの利用 {#install-binary}
バイナリを用いたインストール方法を解説します。  

[tapyrus-coreリポジトリのRelease](https://github.com/chaintope/tapyrus-core/releases){:target="_blank"}でバイナリを配布しています。  
使用環境に応じたバイナリファイルをクリックし、ダウンロードします。　　
![Setup Ubuntu Binary](/assets/images/setup_ubuntu_binary.png)

本記事執筆時点(2022年6月)で公開されている最新バーションが[v0.5.1](https://github.com/chaintope/tapyrus-core/releases/tag/v0.5.1){:target="_blank"}なため、以下のコマンドはx86_64のv0.5.1の圧縮ファイルを解凍する例です。
```
$ tar xzf tapyrus-core-0.5.1-x86_64-linux-gnu.tar.gz
```
解凍したあとのbin以下にパスを通してください。  

以上でインストールは完了です。  
次に、[Tapyrusノードを起動する](#run-tapyrusd)を実施してください。

## (インストール方法2) ソースコードからのビルド {#install-source-code}
Githubに公開されている[tapyrus-core](https://github.com/chaintope/tapyrus-core){:target="_blank"}のソースコードを用いたインストール方法を解説します。

### 依存関係のインストール {#install-dependencies}

依存ライブラリをインストールには以下のコマンドを実行します。  
依存ライブラリ情報は[こちら](https://github.com/chaintope/tapyrus-core/blob/master/doc/dependencies.md){:target="_blank"}で確認できます。
```
$ sudo apt-get install build-essential libtool autotools-dev automake pkg-config libevent-dev bsdmainutils python3 libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev
```

### ビルド {#build}

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
次に、[Tapyrusノードを起動する](#run-tapyrusd)を実施してください。

(任意) インストールするにはさらに以下を実行します。  
以降の解説ではインストールされている前提でコマンドを例示しています。
```
$ sudo make install
```

(任意) インストールするにはさらに以下を実行します。  
以降の解説ではインストールされている前提でコマンドを例示しています。
```
$ sudo make install
```

## Tapyrusノードを起動する {#run-tapyrusd}


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
fallbackfee=0.00001
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
$ tapyrusd -daemon 
```

`tapyrus-cli`の`getblockchaininfo`コマンドを用いて、ブロックチェーンの情報を確認します。
```
$ tapyrus-cli getblockchaininfo
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
$ tapyrus-cli stop
```

以上でUbuntu20.04LTS環境でTapyrus Coreノードが立ち上がり、ChaintopeのTapyrusテストネットと接続ができました。
