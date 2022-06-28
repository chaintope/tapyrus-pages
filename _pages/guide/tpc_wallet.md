---
layout: single
permalink: /guide/tpc_wallet
title: "テストネットからのTPC取得＆送金方法"
---


本記事ではChaintopeが提供するTapyrusのテストネット（networkid 1939510133）上でTapyrusの通貨であるTPCを送受金する方法について解説します。　　
Chaintopeが運営する[Tapyrus Testnet Faucet](https://testnet-faucet.tapyrus.dev.chaintope.com/tapyrus/transactions){:target="_blank"}からTPCを受け取り、tapyrus-coreのCLIを用いてWalletを操作し、送金やトランザクション・ブロックの詳細を確認します。　　

本記事ではTapyrusノードの環境構築方法については解説しません。  
環境構築方法については、以下の記事を参照してください。  
 - [Tapyrus Coreノード構築方法（macOS版）](https://site.tapyrus.chaintope.com/setup/osx)
 - [Tapyrus Coreノード構築方法（Ubuntu版）](https://site.tapyrus.chaintope.com/setup/ubuntu)
 - [Tapyrus Coreノード構築方法（Docker版）](https://site.tapyrus.chaintope.com/setup/docker)



## tapyrus-cliについて

tapyrus-cli以下のような構成で入力を行います。
```
$ tapyrus-cli [options] <command> [params] 
```
- option: コマンドを実行する際に指定する任意の設定。RPC操作を行なうユーザー名・パスワードやWalletの名前など。
- command: 実行したい操作の命令。
- params: コマンドを実行する際に指定する任意の引数。

tapyrus-cliコマンドの詳細は以下は`tapyrus-cli -h`で確認できます。

## Wallet, Addressの作成

TPCを受け取るWalletの作成を行います。
Walletの作成には`tapyrus-cli`の`createwallet`コマンドを用います。
Walletには任意の名前をつけることができ、`createwallet`の後に引数として指定します。
以下のコマンドでは`wallet1`という名前のWalletを作成しています。
```
$ tapyrus-cli createwallet "wallet1"
{
  "name": "wallet1",
  "warning": ""
}
```

まずはWalletの初期状態の確認を行います。  
`getbalance`コマンドを用いて、所有するTPCの量を確認します。  
実行時、`-rpcwallet`オプションで、使用するWalletを指定します。  
`0.00000000`と表示され、コインを所有していないことが分かります。  
```
$ tapyrus-cli -rpcwallet=wallet1 getbalance
0.00000000
```

更に`listunspent`コマンドを用いて、UTXOを確認します。  
これも初期状態のため、空であることが確認できます。  
```
$ tapyrus-cli -rpcwallet=wallet1 listunspent
[
]
```

`getnewaddress`コマンドを用いてアドレスを生成します。  
実行すると表示される文字列が、Walletのアドレスです。  
このアドレスはfaucetからのコイン受取時に使用するため、控えておいてください。  
```
$ tapyrus-cli -rpcwallet=wallet1 getnewaddress
1CuXBp5f3wUAEBongA5TkMK8KehtEFaG2X
```


## faucetからのTPC取得


[Tapyrus Testnet Faucet](https://testnet-faucet.tapyrus.dev.chaintope.com/tapyrus/transactions){:target="_blank"}からTPCを受け取ります。

`Input your address`と表示された入力欄に先程生成したアドレスを入力し、「Get coins!」ボタンをクリックします
![Tapyrus Testnet Faucet](../../assets/images/tpc_wallet_faucet_1.png)


「Withdraw transactions」のリストに自分のアドレス宛のトランザクション情報が表示されるとTPC取得は成功です。
![Withdraw transactions](../../assets/images/tpc_wallet_faucet_2.png)

TPC取得が確定されるためには、トランザクションがSignerノードに承認され、ブロックに取り込まれるのを待つ必要があります。  
Tapyrusではブロックの生成間隔はSignerノードで設定を行います。  
Chaintopeが提供するTapyrusのテストネット（networkid 1939510133）ではブロック生成間隔が10分に設定されているため、faucetからの送金トランザクションが承認されるまでしばらく待ちます。

#### 注意
Faucetに表示された`Current Balance`が0の時、TPCを取得することができません。
その際は、補充されるのをお待ちください。

## 取得したTPCの確認

`getbalance`コマンドを用いて、再度所有するTPCの量を確認します。  
今回は`0.00005528`TPCを所有していることが確認できます。
```
$ tapyrus-cli -rpcwallet=wallet1 getbalance
0.00005528
```

同様に`listunspent`コマンドを用いて、UTXOを確認します。  
faucetから受け取ったがTPCとして表示されます。
```
$ tapyrus-cli -rpcwallet=wallet1 listunspent
[
  {
    "txid": "900491de9863a56320c4fef45b056f8033873838f919a0d47832f12bf4baa5b9",
    "vout": 0,
    "address": "1CuXBp5f3wUAEBongA5TkMK8KehtEFaG2X",
    "token": "TPC",
    "amount": 0.00005528,
    "label": "",
    "scriptPubKey": "76a914829836445162ef8e7701fb5fa1a357b34c92be1788ac",
    "confirmations": 11,
    "spendable": true,
    "solvable": true,
    "safe": true
  }
]
```

## 送金

次にTPCの送金方法について解説します。
同じwalletで別のアドレスを生成し、自分自身に対して送金を行ないます。




送金には`sendtoaddress`コマンドを用います。  
`sendtoaddress`コマンドは"送金先アドレス"、"送金するTPC額"を引数として指定します。  
以下のコマンドのように`sendtoaddress`に続けてコピーしたfaucetのアドレスと` 0.00003528`TPCを指定し実行します。  
```
$ tapyrus-cli -rpcwallet=wallet1 sendtoaddress <faucetのアドレス> 0.00003528
```
実行するとハッシュ値が表示されます。  
これは送金トランザクションのtransaction idです。後ほど詳細確認に使用するため控えておいてください。  


以上で送金は完了です。以降でトランザクションやブロックの詳細情報の確認を行います。

## 送金トランザクション・ブロックの詳細確認


`gettransaction`の引数には先程控えたトランザクションIDを指定します。
```
$ tapyrus-cli -rpcwallet=wallet1 gettransaction <transaction id>
```



```
$ tapyrus-cli -rpcwallet=wallet1 getrawtransaction <transaction id>
```


```
$ tapyrus-cli -rpcwallet=wallet1 getblock <block header>
```

