---
layout: single
permalink: /network/
title: "Tapyrus Network"
description: "Tapyrusテストネットワークの接続情報とFaucet。ネットワークID、マジックバイト、シーダー情報を提供。開発・検証用のテストコインを取得可能。"
---

Tapyrusは誰でもすぐに動作検証ができるよう、テスト用のネットワークおよび、そのネットワークで使用するコインを配布するfaucetを公開しています。

## テスト用ネットワーク {#testnet}
Chaintopeが運営するテスト用のネットワークは以下のパラメータを使用しています。

| ネットワークID | Tapyrusモード | マジックバイト| Tapyrus-seeder    |
| -------------- | ------------  | ------------- | -----------    | 
| 1939510133     | prod          | 0x74839A75    | static-seed.tapyrus.dev.chaintope.com | 

#### ネットワークID  {#network-id}
Tapyrusでは複数のプロダクションネットワークを構築することができます。
ネットワークIDは、それぞれのTapyrusネットワーク識別子です。
Chaintopeが運営するテスト用のネットワークは`1939510133`をネットワークIDとして使用しています。

#### Tapyrusの動作モード {#tapyrus-mode}
Tapyrusでは、プロダクション環境用の`prod`と開発環境用`dev`の2種類の動作モードが用意されており、Chaintopeが運用するテスト用のネットワークは`prod`モードで動作しています。
開発やテストでローカルで単一のTapyrusノードを実行する場合は`dev`モードの使用を推奨します。  

#### マジックバイト {#magic-byte}
マジックバイトはTapyrusネットワーク上のノード間で送信される個別のネットワーク・メッセージを識別する方法として使用されます。
Chaintopeが運営するテスト用のネットワークでは`0x74839A75`をマジックバイトとして使用します。
マジックバイトは、ネットワークIDから以下の計算式で算出されます。
```
(マジックバイト) = 33550335 + (ネットワークID)
```

#### Tapyrus-seeder {#tapyrus-seeder}
[Tapyrus-seeder](https://github.com/chaintope/tapyrus-seeder){:target="_blank"}は、Tapyrusネットワーク用のクローラーで、内蔵のDNSサーバーを介して信頼できるノードのリストを公開します。
Chaintopeが運営するテスト用のネットワークは`static-seed.tapyrus.dev.chaintope.com`をseederとして利用します。  

#### ジェネシスブロック {#genesis-block}
各Tapyrusネットワークは一意のジェネシスブロックを持ちます。
Chaintopeが運営するテスト用のネットワークのジェネシスブロックは以下です。
```
01000000000000000000000000000000000000000000000000000000000000000000000044cc181bd0e95c5b999a13d1fc0d193fa8223af97511ad2098217555a841b3518f18ec2536f0bb9d6d4834fcc712e9563840fe9f089db9e8fe890bffb82165849f52ba5e01210366262690cbdf648132ce0c088962c6361112582364ede120f3780ab73438fc4b402b1ed9996920f57a425f6f9797557c0e73d0c9fbafdebcaa796b136e0946ffa98d928f8130b6a572f83da39530b13784eeb7007465b673aa95091619e7ee208501010000000100000000000000000000000000000000000000000000000000000000000000000000000000ffffffff0100f2052a010000002776a92231415132437447336a686f37385372457a4b6533766636647863456b4a74356e7a4188ac00000000
```

## Tapyrus Testnet Faucet {#tapyrus-testnet-faucet}
Chaintopeが提供するTapyrusのテスト用ネットワークのfaucetとして[Tapyrus Testnet Faucet](https://testnet-faucet.tapyrus.dev.chaintope.com/tapyrus/transactions){:target="_blank"}を運営しています。  
faucetからは誰でもテストネット用の通貨を取得することができます。  

## faucetからのTPC取得＆送金方法 {#get-send-tpc}
ここからはChaintopeが提供するTapyrusのテストネット(ID: 1939510133)上でTapyrusの通貨であるTPCを送受金する方法について解説します。
[Tapyrus Testnet Faucet](https://testnet-faucet.tapyrus.dev.chaintope.com/tapyrus/transactions){:target="_blank"}からTPCを受け取り、tapyrus-coreのCLIを用いてウォレットを操作し、送金やトランザクション・ブロックの詳細を確認します。　　

本記事ではTapyrusノードの環境構築方法については解説しません。
環境構築方法については、以下の記事を参照してください。  
 - [Tapyrus Coreノード構築方法（macOS版）](https://site.tapyrus.chaintope.com/setup/osx)
 - [Tapyrus Coreノード構築方法（Ubuntu版）](https://site.tapyrus.chaintope.com/setup/ubuntu)
 - [Tapyrus Coreノード構築方法（Docker版）](https://site.tapyrus.chaintope.com/setup/docker)


## tapyrus-cliについて {#about-tapyrus-cli}

tapyrus-cliでは、以下のような構成でコマンドを実行します。
```
$ tapyrus-cli [options] <command> [params] 
```
- option: コマンドを実行する際に指定する任意の設定。RPC操作を行なうユーザー名・パスワードや使用するウォレット名など。
- command: 実行したい操作の命令。
- params: コマンドを実行する際に指定する引数。

tapyrus-cliの各コマンドの詳細は`tapyrus-cli -h`で確認できます。

##### Dockerを使用する場合の注意事項 {#notes-docker}
Dockerを使用する場合、全てのコマンド実行時のオプションに`-conf=/etc/tapyrus/tapyrus.conf`を指定する必要があります。  
(実行例)  
```
$ tapyrus-cli -conf=/etc/tapyrus/tapyrus.conf createwallet "wallet1" 
```

## ウォレット, アドレスの作成 {#create-wallet-address}

TPCを受け取るウォレットの作成を行います。  
ウォレットの作成には`tapyrus-cli`の`createwallet`コマンドを用います。  
ウォレットには任意の名前をつけることができ、`createwallet`の後に引数として指定します。  
以下のコマンドでは`wallet1`という名前のウォレットを作成しています。  
```javascript
$ tapyrus-cli createwallet "wallet1"
{
  "name": "wallet1",
  "warning": ""
}
```

ウォレットの初期状態の確認を行います。  
`getbalance`コマンドを用いて、所有するTPCの量を確認します。
実行時、`-rpcwallet`オプションで使用するウォレットを指定します。
`0.00000000`と表示され、TPCを所有していないことが分かります。
```
$ tapyrus-cli -rpcwallet=wallet1 getbalance
0.00000000
```

さらに`listunspent`コマンドを用いて、UTXOを確認します。  
これも初期状態のため、空であることが確認できます。  
```
$ tapyrus-cli -rpcwallet=wallet1 listunspent
[
]
```

`getnewaddress`コマンドを用いてアドレスを生成します。
実行すると表示される文字列がウォレットのアドレスです。
また、ここで生成されるアドレスの種類はP2PKHアドレスです。
このアドレスはfaucetからのコイン受取時に使用するため控えておいてください。
```
$ tapyrus-cli -rpcwallet=wallet1 getnewaddress
1CuXBp5f3wUAEBongA5TkMK8KehtEFaG2X
```


## faucetからのTPC取得 {#get-tpc-from-faucet}
[Tapyrus Testnet Faucet](https://testnet-faucet.tapyrus.dev.chaintope.com/tapyrus/transactions){:target="_blank"}からTPCを受け取ります。  
通過の単位はBTC, satoshiの関係がそのままTPC、tapyrusという単位になっており、それぞれを比較すると`0.00000001 TPC = 1 tapyrus`となります。


`Input your address`と表示された入力欄に先程生成したアドレスを入力し、「Get coins!」ボタンをクリックします。  
![Tapyrus Testnet Faucet](/assets/images/tpc_wallet_faucet_1.png)


「Withdraw transactions」のリストに自分のアドレス宛のトランザクション情報が表示されるとTPC取得は成功です。  
![Withdraw transactions](/assets/images/tpc_wallet_faucet_2.png)

TPC取得が確定されるためには、トランザクションがSignerノードに承認され、ブロックに取り込まれるのを待つ必要があります。  
Tapyrusではブロックの生成間隔はSignerノードで設定を行います。  
Chaintopeが提供するTapyrusのテストネット（networkid 1939510133）ではブロック生成間隔が10分に設定されているため、faucetからの送金トランザクションが承認されるまでしばらく待ちます。  

#### 注意 {#note-faucet}
Faucetに表示された`Current Balance`が0の時、TPCを取得することができません。
その際は、補充されるのをお待ちください。  

## 取得したTPCの確認 {#check-own-tpc}
`getbalance`コマンドを用いて、再度所有するTPCの量を確認します。
今回は`0.00005506`TPCを所有していることが確認できます。　　
```
$ tapyrus-cli -rpcwallet=wallet1 getbalance
0.00005506
```

同様に`listunspent`コマンドを用いて、UTXOを確認します。
faucetから受け取ったTPCがUTXOとして表示されます。
```javascript
$ tapyrus-cli -rpcwallet=wallet1 listunspent
[
  {
    "txid": "8631dbf501ebfbfea02908c2ec8e33b52f61adac3e9ca88ba4fe7aed845e084a",
    "vout": 0,
    "address": "16xEUxgJt7PNZpuXB8w5y7XUzdLnGwZPnP",
    "token": "TPC",
    "amount": 0.00005506,
    "label": "",
    "scriptPubKey": "76a914414ac2d636c7f55d2dcbbc9e568675450d222e0f88ac",
    "confirmations": 1,
    "spendable": true,
    "solvable": true,
    "safe": true
  }
]
```

## 送金 {#send-tpc}

次にTPCの送金方法について解説します。  
本記事では同じウォレットで別のアドレスを生成し、自分自身に対して送金を行ないます。   


再度`getnewaddress`を実行し、新しいアドレスを生成します。
```
$ tapyrus-cli -rpcwallet=wallet1 getnewaddress
1Ky1XpDQ1NUQ5fvssZpAfmdR1nv8mz4nu4
```

送金には`sendtoaddress`コマンドを用います。  
`sendtoaddress`コマンドは"送金先アドレス"、"送金するTPC額"を引数として指定します。
以下のコマンドのように`sendtoaddress`に続けて新しいアドレスと` 0.00001`TPCを指定し実行します。
```
$ tapyrus-cli -rpcwallet=wallet1 sendtoaddress <新しいアドレス> 0.00001
```  

(実行例)
```
$ tapyrus-cli  -rpcwallet=wallet1 sendtoaddress 1Ky1XpDQ1NUQ5fvssZpAfmdR1nv8mz4nu4 0.00001
dae37f4deada8f75a8aa3ab3ec262a26682152b6ec2f83972fd83b93768427de
```

実行するとハッシュ値が表示されます。
これは送金トランザクションのtransaction idです。後ほど詳細確認に使用するため控えておいてください。  


以上で送金は完了です。

## 送金トランザクション・ブロックの詳細確認 {#transaction-block-details}

ここからはトランザクションやブロックの詳細情報を確認する方法を解説します。

トランザクションの詳細情報確認には`getrawtransaction`コマンドを実行します。  
`getrawtransaction`の引数には先程控えておいたtransaction idを使用します。
引数にtransaction idのみを指定した場合、トランザクションのhex値のみが表示され、transaction idの後に`true`または`1`を引数に指定すると、トランザクションの詳細情報が確認できます。
以下のようにtransaction idとtrueを指定してコマンドを実行してください。
```
$ tapyrus-cli -rpcwallet=wallet1 getrawtransaction <transaction id> true
```

実行すると以下のように、JSON形式のトランザクション情報が確認できます。
`blockhash`項目に表示されているハッシュ値をコピーします。
（以下の例では`3dc211432028e6a5b87888cf858bfb96b7524826fcb0b466ba6d3ba9fc77431d`）
```javascript
{
  "txid": "447871e5c4fbc435916c3fe4876bf4e49a7b893658c3369277606486a2c41412",
  "hash": "dc5c63ef4723c0d1de5c1714826b26be0c6f448f79cf5462a0c0de6329d6cdf1",
  "features": 1,
  "size": 225,
  "locktime": 212806,
  "vin": [
    {
      "txid": "939e162ab7064d6c182b6fddd8bb3944b82f3c354e34070b07ed17f3cd57659d",
      "vout": 1,
      "scriptSig": {
        "asm": "30440220125cb34026e50b123861c6d076a09acc2fd21bcb171fb21fbc8e1226a912e9ce022079cebf99a7648467d18fc33e04b6293613fa8f8f38f7b7c71b0a8a8ccc6f9aef[ALL] 035214b49e4b629682760cd3cb7748b537133f41f75e0340c8eee93b926778a455",
        "hex": "4730440220125cb34026e50b123861c6d076a09acc2fd21bcb171fb21fbc8e1226a912e9ce022079cebf99a7648467d18fc33e04b6293613fa8f8f38f7b7c71b0a8a8ccc6f9aef0121035214b49e4b629682760cd3cb7748b537133f41f75e0340c8eee93b926778a455"
      },
      "sequence": 4294967294
    }
  ],
  "vout": [
    {
      "token": "TPC",
      "value": 0.00005467,
      "n": 0,
      "scriptPubKey": {
        "asm": "OP_DUP OP_HASH160 b55e910b603d388e5fd62e376722069ca7c9a2b5 OP_EQUALVERIFY OP_CHECKSIG",
        "hex": "76a914b55e910b603d388e5fd62e376722069ca7c9a2b588ac",
        "reqSigs": 1,
        "type": "pubkeyhash",
        "addresses": [
          "1HXzbKhmRftjByohsXjWB6otWmzUGgANSn"
        ]
      }
    },
    {
      "token": "TPC",
      "value": 98.79934033,
      "n": 1,
      "scriptPubKey": {
        "asm": "OP_DUP OP_HASH160 2b723d85781eaebae9f0808dd0f566c010b9c3a7 OP_EQUALVERIFY OP_CHECKSIG",
        "hex": "76a9142b723d85781eaebae9f0808dd0f566c010b9c3a788ac",
        "reqSigs": 1,
        "type": "pubkeyhash",
        "addresses": [
          "14xiuohWYiyuhMRe3PQKGu76VCCMB27owZ"
        ]
      }
    }
  ],
  "hex": "01000000019d6557cdf317ed070b07344e353c2fb84439bbd8dd6f2b186c4d06b72a169e93010000006a4730440220125cb34026e50b123861c6d076a09acc2fd21bcb171fb21fbc8e1226a912e9ce022079cebf99a7648467d18fc33e04b6293613fa8f8f38f7b7c71b0a8a8ccc6f9aef0121035214b49e4b629682760cd3cb7748b537133f41f75e0340c8eee93b926778a455feffffff025b150000000000001976a914b55e910b603d388e5fd62e376722069ca7c9a2b588ac51d4e34c020000001976a9142b723d85781eaebae9f0808dd0f566c010b9c3a788ac463f0300",
  "blockhash": "3dc211432028e6a5b87888cf858bfb96b7524826fcb0b466ba6d3ba9fc77431d",
  "confirmations": 6,
  "time": 1657149939,
  "blocktime": 1657149939
}
```

次に送金トランザクションが含まれたブロックの情報を確認します。  
`getblock`コマンドの引数として先程控えておいた`blockhash`を指定します。
```
$ tapyrus-cli -rpcwallet=wallet1 getblock <blockhash>
```

以下のように、ブロックの詳細情報がJSON形式で表示されます。
```javascript
{
  "hash": "3dc211432028e6a5b87888cf858bfb96b7524826fcb0b466ba6d3ba9fc77431d",
  "confirmations": 7,
  "strippedsize": 487,
  "size": 487,
  "weight": 1948,
  "height": 212807,
  "features": 1,
  "featuresHex": "00000001",
  "merkleroot": "f5b686f9d40cd79bcfe7a1c4e6ae8068e5d0a71fae47b07f17e40a3dc27c8379",
  "immutablemerkleroot": "a759d5125e9682ffc0aa17e156ff1f117657a73a8c8bac71eaa702165add663e",
  "tx": [
    "76840c85243d2b2cd070139d7a61a84733455c9252f13fabe28936507247ab79",
    "447871e5c4fbc435916c3fe4876bf4e49a7b893658c3369277606486a2c41412"
  ],
  "time": 1657149939,
  "mediantime": 1657148457,
  "xfieldType": 0,
  "proof": "5a00b78a0a92d0ba3ca1aa3fca261829c41c1387cc382d7f87825e6fbbeca3333d779be5087f09963319729a65c7f061b0440e93df8d330976b4e4768715a345",
  "nTx": 2,
  "previousblockhash": "7de860dc7426731a687668e3efc322138b186e0cd45d684525e374085e07a70e",
  "nextblockhash": "60176b6a051b61bf7c4ab16afde490b9c032f13198c365b818df67d91c64ab0c"
}
```

以上で、faucetからのTPC取得＆送金とその確認は完了です。