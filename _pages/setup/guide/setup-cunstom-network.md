---
layout: single
permalink: /guide/setup-custom-netowork
title: "Tapyrus Custom Network構築方法"
---

本記事ではミニマムのTapyrus Neteworkを構築する方法を解説します。
[Tapyrus Signerノードセットアップ方法](/guide/setup_signer_node)の手順に基づき、[tapyrus-signer](https://github.com/chaintope/tapyrus-signer.git){:target="_blank"}をインストールし、セットアップ手順が全て完了している前提で記述します。
公式のドキュメントは[こちら](https://github.com/chaintope/tapyrus-signer/tree/master/docker){:target="_blank"}です。  

また、本記事ではdocker-composeを使用してTapyrus Netwrokを構築します。事前にDockerをインストールしてください。


### Step1. federations.tomlの設定 {#set-federationstoml}
tapyrus-signerの[dockerディレクトリ配下](https://github.com/chaintope/tapyrus-signer/tree/master/docker){:target="_blank"}で作業を行います。
`federations.toml`にSigner Networkのフェデレーションの設定情報を記述します。
まずは`alice`, `bob`, `carol`ディレクトリ配下に`federations.toml`をコピーします。
```
$ cd tapyrus-signer\docker\
$ cd signers
$ cp federations.toml alice/ | cp  federations.toml bob/ | cp  federations.toml carol/
```

`federations.toml`には予め初期状態のブロック高が0、閾値が2で設定されています。
各ディレクトリの`federations.toml`を編集し、`aggregated-public-key`パラメータに、[前記事のStep3](setup_signer_node.md#aggregate)`aggregate`コマンドを実行して生成した集約公開鍵を設定します。
さらに配列形式の`node-vss`パラメータに、Alice, Bob, Carolのそれぞれで`createnodevss`コマンドを使用して生成したノードVSSを設定します。
以下はAliceに設定する`federations.toml`の例です。同様にBob, Carolに集約公開鍵とそれぞれ対応したノードVSSを設定します。
```rust
[[federation]]
block-height = 0
threshold = 2
aggregated-public-key = "<集約公開鍵>"
node-vss = [
    "<AliceのノードVSS>",
    "<Bobが生成したコマンド実行者のノードVSS>",
    "<Carolが生成したのコマンド実行者のノードVSS>"
]
```

## Step2. アドレスの生成 #{#generate-address}
ブロック報酬を受け取るアドレスを予め生成する必要があります。  
アドレスの生成の方法は様々ありますが、本記事では[tapyruseb](https://github.com/chaintope/tapyrusrb){:target="_blank"}ライブラリを用います。  
以下のコマンドでtapyrusebのgemをインストールします。
```
$ gem install tapyrus
```

[Github上のAddress生成用Rubyファイル(generate_address.rb)](https://github.com/chaintope/tapyrus-pages/scripts/generate_address.rb){:target="_blank"}をダウンロードしてください。
ファイルには以下のようなコードが書かれています。  
```ruby
require 'tapyrus'

Tapyrus.chain_params = :prod
key_pair = Tapyrus::Key.generate

puts "秘密鍵(WIF): #{key_pair.to_wif}"
puts "アドレス: #{key_pair.to_p2pkh}"
```

以下のようにファイルの実行、もしくはRubyの対話モード(irb)で上記コードを一行づつ実行してください。  
```
$ ruby generate_address.rb 
```

実行すると以下のような出力が表示されます。
`<秘密鍵>`, `<アドレス>`に表示されている文字列の値を控えておきます。  
```
秘密鍵(WIF): <秘密鍵>
アドレス: <アドレス>
```

## Step3. tapyrus-signer.tomlの設定 {#set-tapyrus-signertoml}
`tapyrus-signer.toml`にはSignerノードの設定を記述します。
まずは`alice`, `bob`, `carol`ディレクトリ配下に`tapyrus-signer.toml`をコピーします。
```
$ cp tapyrus-signer.toml alice/ | cp tapyrus-signer.toml bob/ | cp tapyrus-signer.toml carol/
```

コピーしたそれぞれのファイルを編集します。
`to-address`はブロック生成報酬を受け取るアドレスの設定です。`to-address`に本記事のStep2で生成したアドレスを指定します。
`<signerの公開鍵>`には[前記事のStep1](setup_signer_node.md#createkey)で生成したそれぞれの公開鍵を指定します。
docker-compose.ymlには、RedisとTapyrus Coreがそれぞれホスト名がredis、tapyrusdで、ポートが6379と2377でアクセスできるように設定されています。tomlファイルにも事前に同様の設定情報が記載されています。
```rust
[general]
round-duration = 60
round-limit = 15
log-quiet = false
log-level = "info"
skip-waiting-ibd = true

[signer]
to-address = "<アドレス>"
public-key = "Signerの公開鍵>"
federations-file = "/etc/tapyrus/federations.toml"

[rpc]
rpc-endpoint-host = "tapyrusd"
rpc-endpoint-port = 2377
rpc-endpoint-user = "user"
rpc-endpoint-pass = "pass"

[redis]
redis-host = "redis"
redis-port =  6379
```


## Step4. genesisファイルの移動 {#mv-genesis-file}
次にtapyrusノードの設定に移ります。
[前記事のStep8](setup_signer_node.md#generate-genesis-networkid)で作成したgenesisブロックファイルを`tapyrus-signer/docker/tapyrus`ディレクトリ配下に移動させてください。


## Step5. tapyrus.confファイルの作成 {#set-tapyrusconf}
`tapyrus-signer/docker/tapyrus`ディレクトリ配下に`tapyrus.conf`ファイルを作成します。
`networkid`には[前記事のStep8](setup_signer_node.md#generate-genesis-networkid)で決めたネットワークIDを指定します。
```
$ cat <<EOF >  <tapyrus-signerをcloneしたPATH>/tapyrus-signer/docker/tapyrus/tapyrus.conf
networkid=<ネットワークID>
txindex=1
server=1
rest=1
rpcuser=user
rpcpassword=pass
rpcbind=0.0.0.0
rpcallowip=0.0.0.0/0
EOF
```

以上で各ノードの設定は完了です。

## Step6. コンテナの作成・起動 {#docker-compose-up}
`docker-compose up`を実行し、カスタムネットワークを起動します。

```
$ docker-compose up
```


## Step7. 秘密鍵のインポート {#importprivkey}
ブロック報酬を受け取るアドレスに対応した秘密鍵をtapyrus-coreノードにインポートします。
秘密鍵のインポートには`tapyrus-cli`の`importprivkey`コマンドを使用し、引数にStep2で生成したWIF形式の秘密鍵を指定します。
また、tapyrusdのdockerイメージを使ったコンテナではオプションに`-conf=/etc/tapyrus/tapyrus.conf `を指定する必要があります。
```
$ docker exec docker_tapyrusd_1 tapyrus-cli -conf=/etc/tapyrus/tapyrus.conf importprivkey <秘密鍵>
```

以上でカスタムネットワークの構築は完了です。