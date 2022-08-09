---
layout: single
permalink: /guide/colored-coin
title: "Colored Coin発行・転送・焼却ガイド"
---

この記事ではTapyrus上でColored Coinを発行し、転送、焼却を行なう方法について解説します。
公式のドキュメントは[こちら](https://github.com/chaintope/tapyrus-core/blob/master/doc/tapyrus/colored_coin_ja.md){:target="_blank"}です。  

## 仕様概要 {#specification-overview}
TapyrusにおいてColored Coinは、Bitcoin Scriptを拡張し、`OP_COLOR`opcodeを実装したことにより実現されています。
スクリプト内に`OP_COLOR`opcodeが現れると、スタックの一番上の要素がCOLOR識別子として使われます。後述するルールに従ったCOLOR識別子を持つことにより以下の三種類のトークンが発行可能です。
- 再発行可能なトークン
- 再発行不可能なトークン
- NFT

既存のP2PKHとP2SHをカラーリングした以下のタイプのscriptPubkeyをサポートしています。

CP2PKH(Colored P2PKH)：
```
<COLOR識別子> OP_COLOR OP_DUP OP_HASH160 <公開鍵のハッシュ値> OP_EQUALVERIFY OP_CHECKSIG
```

CP2SH(Colored P2SH)：
```
<COLOR識別子> OP_COLOR OP_HASH160 <H(redeem script)> OP_EQUAL
```

### COLOR識別子 {#color-identifier}
COLOR識別子は1バイトのTYPEと、32バイトのPAYLOADで構成されます。
COLOR識別子が現在サポートするタイプと、対応するペイロードは以下の通りです。

TYPE|定義|PAYLOAD
---|---|---
0xC1|再発行可能なトークン|発行インプットのscriptPubkeyのSHA256値である32バイトのデータ
0xC2|再発行不可能なトークン|発行インプットのOutPointのSHA256値である32バイトのデータ
0xC3|NFT|発行インプットのOutPointのSHA256値である32バイトのデータ

### トークンの発行 {#issue-token}
UTXO から上記のルールをベースに COLOR 識別子を導出し、CP2PKH、CP2SHなどのスクリプトをセットしたトランザクション作成し、公開します。

### トークンの送付 {#transfer-token}
トークンを持つUTXOをインプットにしたトランザクションを作成し、 送金先のアドレスに対して、インプットのトークンと同じCOLOR識別子と`OP_COLOR`opcodeを付与したアウトプットを追加します。

### トークンの焼却 {#burn-token}
焼却するトークンを持つUTXOと手数料用のTPCを持つUTXOをインプットにしたトランザクションを作成し、 手数料を差し引いたTPCのお釣りを受け取るアウトプットを追加します。

また、上記３つのトークン処理を１つのトランザクションを組み合わせることも可能です。

各組み合わせおよび有効/無効のパターンについては、[こちら](https://docs.google.com/spreadsheets/d/1hYEe5YVz5NiMzBD2cTYLWdOEPVUkTmVIRp8ytypdr2g/)の資料に掲載されています。


## コマンド概要 {#commands}
ここからは実際にTapyrusを用いて、Colored Coinを発行し、転送、焼却を行なう方法について解説します。

## 前提 {#prerequisites}
本記事ではTapyrusノードの環境構築方法については解説しません。
環境構築方法については、以下の記事を参照してください。  
 - [Tapyrus Coreノード構築方法（macOS版）](https://site.tapyrus.chaintope.com/setup/osx)
 - [Tapyrus Coreノード構築方法（Ubuntu版）](https://site.tapyrus.chaintope.com/setup/ubuntu)
 - [Tapyrus Coreノード構築方法（Docker版）](https://site.tapyrus.chaintope.com/setup/docker)
 - [Tapyrus Coreノード devモード起動方法（Docker版）](https://site.tapyrus.chaintope.com/setup/dev-docker)
 - [Tapyrus Coreノード devモード起動方法（MacOS/Ubuntu版）](https://site.tapyrus.chaintope.com/setup/dev-local)

## 準備 {#preparation}
walletを作成し、TPCの受け取りを行なうアドレスを生成します。
```
$ tapyrus-cli createwallet test
$ tapyrus-cli -rpcwallet=test getnewaddress
<アドレス>
```

以降のコマンド実行時には、使用するウォレットを明示する`-rpcwallet=test`オプションを指定します。
本記事ではTPCの受け取り方法については解説しません。ネットワークに応じた方法で、TPCの受け取りを行っておください。

## 発行 {#issue}

トークンの発行には`issuetoken`コマンドを用います。
```
tapyrus-cli issuetoken <トークンタイプ> <トークン発行量> <transaction id/scriptpubkey> <index> 
```

- "トークンタイプ"(数値, **必須**): 以下のトークンの種類に応じた数値を入力することで、発行するトークンの種類を指定します。
  - 1: 再発行可能なトークン
  - 2: 再発行不可能なトークン
  - 3: NFT
- "トークン発行量"(数値, **必須**): 発行するトークンの量。
- "scriptpubkey/transaction id"(文字列, 任意): 発行するトークンの種類によって引数に指定する値が異なります。任意の引数ですがトークンの種類にしたがって、以下のどちらかを必ず指定する必要があります。
  - "scriptpubkey":  再発行可能なトークン
  - "transaction id": 再発行不可能なトークン/NFT
- "index"(数値, 任意): トランザクションのアウトプットのindex。再発行不可能なトークン/NFTの場合必ず指定する必要があります。

### 再発行可能なトークン {#reissuable-token}
再発行可能トークンには`scriptPubKey`を取得する必要があります。
`getaddressinfo`コマンドを用いて引数に先程生成したアドレスを指定します。
```
tapyrus-cli getaddressinfo <アドレス>
```

##### 入力例 {#reissuable-token-example}
`getaddressinfo`コマンドを実行し、出力されたJSONオブジェクトの`scriptPubKey`項目を控えておきます。
```javascript
$ tapyrus-cli -rpcwallet=test getaddressinfo mhSs9ykDVWbPvUw12iG3KspEYbWaBLB54y
{
  "address": "mhSs9ykDVWbPvUw12iG3KspEYbWaBLB54y",
  "token": "TPC",
  "scriptPubKey": "76a914152a4c370331b0409a065cd40654bb9250af36a788ac",
  "ismine": true,
  "iswatchonly": false,
  "isscript": false,
  "istoken": false,
  "pubkey": "03fb35352aadde959f80299e2cd4a2770fbcdd8b8b5315eedb4b8937d58b7f3873",
  "iscompressed": true,
  "label": "",
  "timestamp": 1659570172,
  "hdkeypath": "m/0'/0'/0'",
  "hdseedid": "16d50d225a9e7446d0765b870c459b5d03e6cd9c",
  "hdmasterkeyid": "16d50d225a9e7446d0765b870c459b5d03e6cd9c",
  "labels": [
    {
      "name": "",
      "purpose": "receive"
    }
  ]
}
```

`issuetoken`コマンドを用いて再発行可能なトークンを発行します。
`トークンタイプ`には`1`を指定し、任意の`トークン発行量`を指定します。次に先程控えた`scriptPubKey`指定します。`index`引数は指定しません。
実行するとJSON形式のオブジェクトが出力されます。`color`プロパティがCOLOR識別子で、`txids`配列に表示されるのがカラードコインの発行トランザクションとお釣りトラザクションの`txid`です。
```javascript
$ tapyrus-cli -rpcwallet=test issuetoken 1 100 76a914152a4c370331b0409a065cd40654bb9250af36a788ac
{
  "color": "c15f8dbe022c47bf14b62976b7b10b3a95ce4b6e12aa4b11cfb342c6bd63689720",
  "txids": [
    "4cc4699206fd0f0e2966663a7981d22b182933691fb1b1d9e6e0ffe68462effc",
    "875a6a0c18e7ac566a9db0173718406440440ff9f0dd6d4f031c2ac1aba72285"
  ]
}
```

### 再発行不可能なトークン(NON-REISSUABLE Token) {#non-reissuable-token}
トークンの発行に使用する未使用のトランザクション情報の確認に`listunspent`コマンドを用います。
```javascript
$ tapyrus-cli -rpcwallet=test listunspent
[
  {
    "txid": "986db9c02763f5bf266eee0325610d0d245102d7be461ddc7ed21ddd2eb7a2f0",
    "vout": 0,
    "address": "mma9LALzWZTapAMxB9gN1CDCbNhJxuCwQr",
    "token": "TPC",
    "amount": 50.00000000,
    "label": "",
    "scriptPubKey": "76a914426b371b81a6da4b5ee616de7f7328b36fb813ec88ac",
    "confirmations": 14,
    "spendable": true,
    "solvable": true,
    "safe": true
  }
]
```

`txid`に表示されている値と`vout`に表示されている値を指定します。
```javascript
$ tapyrus-cli -rpcwallet=test issuetoken 2 1000 986db9c02763f5bf266eee0325610d0d245102d7be461ddc7ed21ddd2eb7a2f0 0
{
  "color": "c25f652da6dd59ea3fe064fc32c2a8299d0decd30a5a176bae1922a4cce1f5ac93",
  "txid": "82ef88fbbc7009d5ec8f60a488643c8843e75c3cea5e19a6b9598867689908b7"
}
```

### NFT(NON-FUNGIBLE token) {#non-fungible-token}
NFTでは`トークン発行量`は`1`を指定しなければいけません。
```javascript
$ tapyrus-cli -rpcwallet=test issuetoken 3 1 1769ee16bcaf7a09bb26dace6e87cc491d05fe8c7049fb2c7a03375b424265cd 0
{
  "color": "c3e580f95dc615babb8d12da873e941b1f78dd474390fd3635856475cae8db07e0",
  "txid": "f3ba60ade2fff547de546bc74121ccd9b2f60b44ac538297a6b552683fe6d8cc"
}
```

## 詳細確認 {#check-details}
発行したトークンを確認します。
`listunspent`を実行し、`token`プロパティに`TPC`ではなく、COLOR識別子が表示されているオブジェクトがトークンの情報です。
```javascript
$ tapyrus-cli -rpcwallet=test listunspent
[
    {
    "txid": "c1121dd7b1903e06d064d878a217360fa56242032af372e6b62b00d36367682b",
    "vout": 0,
    "address": "2oLLFe3GXLW3nNGJZyJFJhfopsWT93SpnRkiA4cVHniVekbDeT6ntBMZhjCCcWFuHsmPptnCCqgs1E23",
    "token": "c165120022f13a32940ace3dfebd4fef9843e3e7888445ae93374b5625a06e56f2",
    "amount": 100,
    "label": "",
    "scriptPubKey": "21c165120022f13a32940ace3dfebd4fef9843e3e7888445ae93374b5625a06e56f2bca914ef9aed45043c3956181d82511c9bb63a26c5d28187",
    "confirmations": 1,
    "spendable": true,
    "solvable": true,
    "safe": true
  }
]
```

コマンドの所有量確認には`getbalance`コマンドを用います。
引数に`false`とCOLOR識別子を指定し、実行すると指定したトークンの所有量が表示されます。
```
$ tapyrus-cli -rpcwallet=test getbalance false c15f8dbe022c47bf14b62976b7b10b3a95ce4b6e12aa4b11cfb342c6bd63689720
100
```

COLOR識別子だけを取得したい場合、`getcolor`コマンドを用います。
`トークンタイプ`、`transaction id/scriptpubkey`、`index`を引数に指定し実行すると、COLOR識別子が出力されます。
```
tapyrus-cli getcolor <トークンタイプ>  <transaction id/scriptpubkey> <index> 
```

##### 入出力例 {#check-details-example}
```
$ tapyrus-cli -rpcwallet=test getcolor 3 fc57e9162eb049cc343d734860026300fb68488b4e3b157cc083526255736770 0
c3ba0a3d75ab880bf7458623859a6ca5cbc61947eba06042331b03da6b8114cc28
```

## 転送 {#transfer}
COLOR識別子に対応したアドレスを生成する必要があります。
COLOR識別子を引数に、`getrawchangeaddress`コマンドを実行します。
実行すると通常のアドレスよりも長いCOLOR識別子に対応したアドレスが出力されます。
```
$ tapyrus-cli -rpcwallet=test getrawchangeaddress c15f8dbe022c47bf14b62976b7b10b3a95ce4b6e12aa4b11cfb342c6bd63689720
22VKiyVLbGxG1cC5xhBh79awwAJoAPnM8LNVnBSK9SJvsgEM1aAPCQSn35w2mVvFf8PmzEa3uVWgKwpY
```

トークンの転送は`transfertoken`コマンドを用います。
引数に`転送先のCOLOR識別子に対応したアドレス`と`転送するトークンの量`を指定します。
```
$ tapyrus-cli transfertoken <COLOR識別子に対応したアドレス> <トークン転送量>
```


##### 入出力例 {#transfer-example}
コマンドを実行すると`transaction id`が出力されます。
```
$ tapyrus-cli -rpcwallet=test transfertoken 22VKiyVLbGxG1cC5xhBh79awwAJoAPnM8LNVnBSK9SJvsgEM1aAPCQSn35w2mVvFf8PmzEa3uVWgKwpY 10
9716f384090bba30e34d4277fcfe3f2722814d1991e25069996ba70d53bca24e
```


```javascript
$ tapyrus-cli -rpcwallet=test getrawtransaction 9716f384090bba30e34d4277fcfe3f2722814d1991e25069996ba70d53bca24e true
{
  "txid": "9716f384090bba30e34d4277fcfe3f2722814d1991e25069996ba70d53bca24e",
  "hash": "baf9bd2857d208697099dd0e1a53cced6374e4e899072b93b2d0b675232f367c",
  "features": 1,
  "size": 225,
  "locktime": 13,
  "vin": [
    {
      "txid": "f0b7521cd97fab5ad32aa9890e199f50cb9bb632c536dd26cc1dcb0640c23517",
      "vout": 1,
      "scriptSig": {
        "asm": "3044022030eb1b84969f5a915f662ff8295ac474414cb634b0328b861964e0ee29d60db502207106b0d80f62fca32e9d4f025037a45dd010a907796ab1da7be7dd6b25849bfb[ALL] 036dc26ec69ccbedc4549ab12bd89d1c49d4e6a5f2b9240ae7a81d76ac99480224",
        "hex": "473044022030eb1b84969f5a915f662ff8295ac474414cb634b0328b861964e0ee29d60db502207106b0d80f62fca32e9d4f025037a45dd010a907796ab1da7be7dd6b25849bfb0121036dc26ec69ccbedc4549ab12bd89d1c49d4e6a5f2b9240ae7a81d76ac99480224"
      },
      "sequence": 4294967294
    }
  ],
  "vout": [
    {
      "token": "TPC",
      "value": 10.00000000,
      "n": 0,
      "scriptPubKey": {
        "asm": "OP_DUP OP_HASH160 4ea4cd4b223d847df2520adb5d82db5880bd68dc OP_EQUALVERIFY OP_CHECKSIG",
        "hex": "76a9144ea4cd4b223d847df2520adb5d82db5880bd68dc88ac",
        "reqSigs": 1,
        "type": "pubkeyhash",
        "addresses": [
          "mngnReyGQygcMKqxZ7Dxaz8GsAtp1uaiFZ"
        ]
      }
    },
    {
      "token": "TPC",
      "value": 39.99965840,
      "n": 1,
      "scriptPubKey": {
        "asm": "OP_DUP OP_HASH160 7a62af89f484a79c22dd8e89fd059d0fe7b9b947 OP_EQUALVERIFY OP_CHECKSIG",
        "hex": "76a9147a62af89f484a79c22dd8e89fd059d0fe7b9b94788ac",
        "reqSigs": 1,
        "type": "pubkeyhash",
        "addresses": [
          "mrg4xG2XYmHv6HznaESXsZHtfgPZq8WaTa"
        ]
      }
    }
  ],
  "hex": "01000000011735c24006cb1dcc26dd36c532b69bcb509f190e89a92ad35aab7fd91c52b7f0010000006a473044022030eb1b84969f5a915f662ff8295ac474414cb634b0328b861964e0ee29d60db502207106b0d80f62fca32e9d4f025037a45dd010a907796ab1da7be7dd6b25849bfb0121036dc26ec69ccbedc4549ab12bd89d1c49d4e6a5f2b9240ae7a81d76ac99480224feffffff0200ca9a3b000000001976a9144ea4cd4b223d847df2520adb5d82db5880bd68dc88ac90a26aee000000001976a9147a62af89f484a79c22dd8e89fd059d0fe7b9b94788ac0d000000",
  "blockhash": "9ee26cf50986361fa713dee4ad0a9fff2503814b3e659eddfd3a783ae3f742e3",
  "confirmations": 3,
  "time": 1659661981,
  "blocktime": 1659661981
}
```

## 焼却 {#burn}
トークンの焼却には`burntoken`コマンドを用います。
引数には焼却するトークンの`COLOR識別子`と`焼却量`を指定します。
```
$ tapyrus-cli burntoken <COLOR識別子> <焼却量>
```

##### 入出力例 {#burn-example}
コマンドを実行すると`transaction id`が出力されます。
```
$ tapyrus-cli -rpcwallet=test burntoken c15f8dbe022c47bf14b62976b7b10b3a95ce4b6e12aa4b11cfb342c6bd63689720 10
f9784313ce52f6ee0bde2d1b18cd6687ef1c88e4fae06d805a1b244a5a6cb631
```

`getrawtransaction`コマンドでトランザクションの詳細が確認できます。
```javascript
$ tapyrus-cli -rpcwallet=test getrawtransaction f9784313ce52f6ee0bde2d1b18cd6687ef1c88e4fae06d805a1b244a5a6cb631 true
{
  "txid": "f9784313ce52f6ee0bde2d1b18cd6687ef1c88e4fae06d805a1b244a5a6cb631",
  "hash": "3780762b18abc0e213920711b8be702138b2c06e2564d8e9304f4a65c429b20b",
  "features": 1,
  "size": 327,
  "locktime": 15,
  "vin": [
    {
      "txid": "9716f384090bba30e34d4277fcfe3f2722814d1991e25069996ba70d53bca24e",
      "vout": 0,
      "scriptSig": {
        "asm": "304402202e622eb6cb42108ab20ed5f53ca71d8ece4b6b6233a63bad339b975181ad943a0220706640d4282bec18ed065074d0742fa5a299c3c63d5d853efddb482334d6d9e8[ALL] 0285ec8aa4b0b9410fa87d4eb7d3273690011a315500c4549327800357d9f81309",
        "hex": "47304402202e622eb6cb42108ab20ed5f53ca71d8ece4b6b6233a63bad339b975181ad943a0220706640d4282bec18ed065074d0742fa5a299c3c63d5d853efddb482334d6d9e801210285ec8aa4b0b9410fa87d4eb7d3273690011a315500c4549327800357d9f81309"
      },
      "sequence": 4294967294
    },
    {
      "txid": "875a6a0c18e7ac566a9db0173718406440440ff9f0dd6d4f031c2ac1aba72285",
      "vout": 0,
      "scriptSig": {
        "asm": "76a9145266eb758353619fe3d58c2fdbde91c75073653588ac",
        "hex": "1976a9145266eb758353619fe3d58c2fdbde91c75073653588ac"
      },
      "sequence": 4294967294
    }
  ],
  "vout": [
    {
      "token": "c15f8dbe022c47bf14b62976b7b10b3a95ce4b6e12aa4b11cfb342c6bd63689720",
      "value": 90,
      "n": 0,
      "scriptPubKey": {
        "asm": "c15f8dbe022c47bf14b62976b7b10b3a95ce4b6e12aa4b11cfb342c6bd63689720 OP_COLOR OP_DUP OP_HASH160 29817222b1f04bd02e82043042e14b60adc5b37f OP_EQUALVERIFY OP_CHECKSIG",
        "hex": "21c15f8dbe022c47bf14b62976b7b10b3a95ce4b6e12aa4b11cfb342c6bd63689720bc76a91429817222b1f04bd02e82043042e14b60adc5b37f88ac",
        "reqSigs": 1,
        "type": "coloredpubkeyhash",
        "addresses": [
          "22VKiyVLbGxG1cC5xhBh79awwAJoAPnM8LNVnBSK9SJvsgE1yvrpspfMMPoatKV7jc7Nd4eT5ZwmyHQY"
        ]
      }
    },
    {
      "token": "TPC",
      "value": 9.99993460,
      "n": 1,
      "scriptPubKey": {
        "asm": "OP_DUP OP_HASH160 29817222b1f04bd02e82043042e14b60adc5b37f OP_EQUALVERIFY OP_CHECKSIG",
        "hex": "76a91429817222b1f04bd02e82043042e14b60adc5b37f88ac",
        "reqSigs": 1,
        "type": "pubkeyhash",
        "addresses": [
          "mjJR4ySFZSj2Bg5PUshiDWEkffaTS9VeEx"
        ]
      }
    }
  ],
  "hex": "01000000024ea2bc530da76b996950e291194d8122273ffefc77424de330ba0b0984f31697000000006a47304402202e622eb6cb42108ab20ed5f53ca71d8ece4b6b6233a63bad339b975181ad943a0220706640d4282bec18ed065074d0742fa5a299c3c63d5d853efddb482334d6d9e801210285ec8aa4b0b9410fa87d4eb7d3273690011a315500c4549327800357d9f81309feffffff8522a7abc12a1c034f6dddf0f90f44406440183717b09d6a56ace7180c6a5a87000000001a1976a9145266eb758353619fe3d58c2fdbde91c75073653588acfeffffff025a000000000000003c21c15f8dbe022c47bf14b62976b7b10b3a95ce4b6e12aa4b11cfb342c6bd63689720bc76a91429817222b1f04bd02e82043042e14b60adc5b37f88ac74b09a3b000000001976a91429817222b1f04bd02e82043042e14b60adc5b37f88ac0f000000"
}
```

## 再発行 {#reissue}
再発行可能なトークンの再発行方法について解説します。
`reissuetoken`コマンドを用います。引数に`再発行可能なトークンのCOLOR識別子`と`再発行するトークンの量`を指定します。
```
tapyrus-cli reissuetoken <再発行可能なトークンのCOLOR識別子> <再発行量>
```

##### 入出力例 {#reissue-token}
再発行可能なトークンの`issuetoken`コマンド実行時と同様のJSON形式のオブジェクトが出力されます。
```javascript
$ tapyrus-cli -rpcwallet=test reissuetoken c15f8dbe022c47bf14b62976b7b10b3a95ce4b6e12aa4b11cfb342c6bd63689720 50
{
  "color": "c15f8dbe022c47bf14b62976b7b10b3a95ce4b6e12aa4b11cfb342c6bd63689720",
  "txids": [
    "58ac30f98618ba16911fd2e5d42fb3eb0696db048446e196fc083639c886e867",
    "31a0622546efa94e82acd59eb847c00c8a8cfa114fa320a9ae74ba687d5f95bf"
  ]
}
```