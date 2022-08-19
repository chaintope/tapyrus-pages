---
layout: single
permalink: /guide/tapyrusrb
title: "tapyrusrb ガイド"
---

この記事ではTapyruys rubyライブラリであるtapyrusrbの使用方法を解説します。
[こちら](https://github.com/chaintope/tapyrus-pages/tree/master/scripts){:target="_blank"}に各項目のサンプルコードがあります。
公式ドキュメントは[こちら](https://github.com/chaintope/tapyrusrb/wiki){:target="_blank"}です。

## tapyrsurbとは？ {#about-tapyrusrb}
tapyrsurbとはTapyrusの基本機能を全て実装したrubyライブラリです。
実装さている機能には以下のようなものがあります。

- Tapyrusスクリプトインタプリタ
- Tapyrusプロトコルネットワークメッセージのデシリアライゼーション
- ブロックとトランザクションのデシリアライゼーション
- SchnorrとECDSAの鍵生成と検証（BIP-32とBIP-39のサポートを含む）
- ECDSA署名(RFC6979 -決定論的ECDSA, LOW-S, LOW-R対応)
- [WIP] SPVノード
- [WIP】0ff-chainプロトコル

## セットアップ方法 {#setup}

### Level DBのインストール {#setup-leveldb}
tapyrusrbライブラリをインストールするためには、まずLevel DBをインストールする必要があります。
各環境に応じた以下のコマンドを実行してください。

Ubuntu環境の場合:
```
$ sudo apt-get install libleveldb-dev
```

Mac環境の場合:
```
$ brew install leveldb
```

### leveldb-nativeのインストール {#setup-leveldb-native}
次にleveldb用のgemである`leveldb-native`をインストールします
```
$ gem install leveldb-native
```

### tapyrusrbのインストール {#setup-tapyrusrb}
`tapyrusrb`をインストールします
```
$ gem install tapyrus
```

tapyrusrbのモジュールを使用するためには、requireで読み込みをする必要があります。
```
require 'tapyrus'
```

## RPC呼び出し {#rpc-call}
[TapyrusCoreClientモジュール](https://github.com/chaintope/tapyrusrb/blob/master/lib/tapyrus/rpc/tapyrus_core_client.rb){:target="_blank"}を用いることで、TapyrusCoreに対してRPC呼び出しを行なうことができます。

### createwallet {#rpc-call-createwallet}
`config`変数に実行中のTapyrus Coreの設定を行い、TapyrusCoreClientインスタンスの生成を行います。
ウォレットの名前を引数に指定し、`createwallet`メソッドを使用することで、createwallet命令が実行されます。
```ruby
config =  { schema: 'http', host: 'localhost', port: 12381, user: 'user', password: 'pass' }
client = Tapyrus::RPC::TapyrusCoreClient.new(config)
puts client.createwallet("rbtest")
```

実行すると、以下のようにRPCの実行結果が出力されます。
```
{"name"=>"rbtest", "warning"=>""}
```


### listunspent {#rpc-call-listunspent}
特定のウォレットを使用する命令を実行する場合、`config`にwallet名を指定する必要があります。
```ruby
config =  { schema: 'http', host: 'localhost', port: 12381, user: 'user', password: 'pass', wallet: "rbtest" }
client = Tapyrus::RPC::TapyrusCoreClient.new(config)
puts client.listunspent
```

ウォレットが資金を持っている場合、実行すると以下のように出力されます。資金を持っていない場合、何も表示されません。
```
{"txid"=>"82ef88fbbc7009d5ec8f60a488643c8843e75c3cea5e19a6b9598867689908b7", "vout"=>1, "address"=>"mryyM31hokZSBfjVMFhNfAN8PtzS9EmoS2", "token"=>"TPC", "amount"=>"49.99994840", "scriptPubKey"=>"76a9147dc57e04a79379bffeb61f3d5ddd1d0cc94bfbe288ac", "confirmations"=>1, "spendable"=>true, "solvable"=>true, "safe"=>true}
{"txid"=>"5da116c8b9f6b85fb8ff26428ddf2d71cb1cb230a4ea6767759cebe9045616f0", "vout"=>0, "address"=>"mma9LALzWZTapAMxB9gN1CDCbNhJxuCwQr", "token"=>"TPC", "amount"=>"50.00000000", "label"=>"", "scriptPubKey"=>"76a914426b371b81a6da4b5ee616de7f7328b36fb813ec88ac", "confirmations"=>11, "spendable"=>true, "solvable"=>true, "safe"=>true}
```


## 鍵ペア作成 {#generate-keypair}
鍵ペアの作成には[Keyモジュール](https://github.com/chaintope/tapyrusrb/blob/master/lib/tapyrus/key.rb){:target="_blank"}を使用します。
```ruby
key_pair = Tapyrus::Key.generate
puts "秘密鍵(WIF): #{key_pair.to_wif}"
puts "公開鍵： #{key_pair.pubkey}"
```

実行結果例:
```
秘密鍵(WIF): cMx36XoeCWx6fCMYXRn8J999fn4BuTkw7PaYm4tBBEMPKT3NHZgL
公開鍵： 0201c315cd4bde40c098aa2251227aff1cd3f462c57993a31de3648c27c919a748
```

サンプルコードは[こちら](https://github.com/chaintope/tapyrus-pages/scripts/tree/master/generate_key_pair.rb){:target="_blank"}です。

## アドレスの生成 {#generate-address}
アドレスの生成は、鍵ペアの作成と同様に[Keyモジュール](https://github.com/chaintope/tapyrusrb/blob/master/lib/tapyrus/key.rb){:target="_blank"}を使用します。
```ruby
key_pair = Tapyrus::Key.generate
puts "秘密鍵(WIF): #{key_pair.to_wif}"
puts "アドレス: #{key_pair.to_p2pkh}"
```

サンプルコードは[こちら](https://github.com/chaintope/tapyrus-pages/scripts/tree/master/generate_address.rb){:target="_blank"}です。

## トランザクション作成、署名 {#generate-transaction}
次に送金、 再発行可能なトークン発行、再発行不可能なトークン発行、NFT発行のトランザクション作成と署名方法について解説します。
各種トランザクション作成には[TxBuilderモジュール](https://github.com/chaintope/tapyrusrb/blob/master/lib/tapyrus/tx_builder.rb){:target="_blank"}を使用します。

トランザクションの作成には、以下のような`script_pubkey`, `txid`、`index`、`value`キーを持つハッシュオブジェクトの変数を定義する必要があります。
`listunspend`コマンド等を用いてUTXOを取得し、変数を定義してください。
```ruby
utxo = {
  script_pubkey: <script_pubkeyの文字列>,
  txid: <txidの文字列>,
  index: <indexの数値>,
  value: <amountの数値>
}
```

### 送金トランザクションの作成 {#generate-pay-transaction}
TxBuilderインスタンスを生成し、add_utxoメソッドで使用するUTXOを指定します。
payメソッドに送金先のアドレスと、送金するTPCの量を指定し、buildメソッドを呼び出すとTransactionインスタンスが生成されます。
```ruby
key_pair = Tapyrus::Key.generate
tx_builder = Tapyrus::TxBuilder.new.fee(1_000) 
pay_tx = tx_builder.add_utxo(utxo).change_address(key_pair.to_p2pkh).pay(key_pair.to_p2pkh, 1_000).build
puts "トランザクションID: #{pay_tx.txid}"
puts "未署名の送金トランザクション(hex): #{pay_tx.to_hex}"
```

実行結果例:
```
トランザクションID: 0859e1dceef87bcd6b56d75a3b1f2c1762f4c7d4732fc58f8a74f7988bb626d4
未署名の送金トランザクション(hex): 0100000001f0165604e9eb9c756767eaa430b21ccb712ddf8d4226ffb85fb8f6b9c816a15d0000000000ffffffff02e8030000000000001976a9140a3e199ac283546368f1693452194d23f0b6923488ace8030000000000001976a9140a3e199ac283546368f1693452194d23f0b6923488ac00000000
```


### 再発行可能なトークン発行トランザクションの作成 {#generate-reissuable-transaction}
reissuableメソッドの引数にパースしたscript_pubkeyとアドレス、発行量を指定し、buildメソッドを呼び出します。
```ruby
key_pair = Tapyrus::Key.generate
tx_builder = Tapyrus::TxBuilder.new.fee(1_000) 
non_reissuable_tx = tx_builder.add_utxo(utxo).reissuable(Tapyrus::Script.parse_from_payload(utxo[:script_pubkey]), key_pair.to_p2pkh, 10_000).build
puts "トランザクションID: #{non_reissuable_tx.txid}"
puts "未署名の再発行可能なトークン発行トランザクション(hex): #{non_reissuable_tx.to_hex}"
```

### 再発行不可能なトークン発行トランザクションの作成 {#generate-non-reissuable-transaction}
non_reissuableメソッドの引数にトランザクションのアウトポイントとアドレス、発行量を指定し、buildメソッドを呼び出します。
```ruby
key_pair = Tapyrus::Key.generate
tx_builder = Tapyrus::TxBuilder.new.fee(1_000) 
non_reissuable_tx = tx_builder.add_utxo(utxo).non_reissuable(Tapyrus::OutPoint.from_txid(utxo[:txid], utxo[:index]), key_pair.to_p2pkh, 10_000).build
puts "トランザクションID: #{non_reissuable_tx.txid}"
puts "再発行不可能なトークン発行トランザクション(hex): #{non_reissuable_tx.to_hex}
```


### NFT発行トランザクションの作成 {#generate-nft-transaction}
NFTは再発行不可能なトークンと同様に、reissuableメソッドにトランザクションのアウトポイントとアドレス、発行量を指定し、buildを呼び出します。
```ruby
key_pair = Tapyrus::Key.generate
tx_builder = Tapyrus::TxBuilder.new.fee(1_000) 
nft_tx = tx_builder.add_utxo(utxo).nft(Tapyrus::OutPoint.from_txid(utxo[:txid], utxo[:index]), key_pair.to_p2pkh).build
puts "トランザクションID: #{nft_tx.txid}"
puts "未署名のNFT発行トランザクション(hex): #{nft_tx.to_hex}"
```


### 署名  {#sign-transaction}
署名にはKeyモジュールのsignメソッドを用います。
signメソッドには引数としてsignature hashを指定する必要があります。
```ruby
sig_hash = pay_tx.sighash_for_input(utxo[:index], Tapyrus::Script.parse_from_payload(utxo[:script_pubkey]))
signature = key_pair.sign(sig_hash) + [Tapyrus::SIGHASH_TYPE[:all]].pack('C')
pay_tx.in[0].script_sig << signature
pay_tx.in[0].script_sig << key_pair.pubkey.htb
puts "トランザクションID: #{pay_tx.txid}"
puts "署名後の送金トランザクション(hex): #{pay_tx.to_hex}"
```

実行結果例:
```
トランザクションID: 4cb35922035998bcdab0dc57058f52b92de30b8fffc1421ca9cf49940715517c
署名後の送金トランザクション(hex): 0100000001f0165604e9eb9c756767eaa430b21ccb712ddf8d4226ffb85fb8f6b9c816a15d000000006a4730440220668d5124f377bd49b580902b108aa4d7345b58682000b85e32d5de6eec77967302202c374cc771a07c96ec20bb5709ab51416e217c88695f9088293a760cf041036e0121020c295f28953568cda55b46a60c23a11132a5f72ef6345edfc9cd2dc175b6a5e9ffffffff02e8030000000000001976a914804abcb8f7cb0be5c9f11f8d9d21a307f25ca04e88ace8030000000000001976a914804abcb8f7cb0be5c9f11f8d9d21a307f25ca04e88ac00000000
```

サンプルコードは[こちら](https://github.com/chaintope/tapyrus-pages/scripts/tree/master/generate_transaction.rb){:target="_blank"}です。

## COLOR識別子の導出 {#generate-color-id}
COLOR識別子の導出にはscript_pubkeyかtxidとindexを用います。
以下のように予めキーペアの生成とtxidとindexを変数として定義しておいてください。

```ruby
key_pair = Tapyrus::Key.generate
txid = '82ef88fbbc7009d5ec8f60a488643c8843e75c3cea5e19a6b9598867689908b7'
index = 1
```


### 再発行可能なトークン {#generate-color-id-reissuable}
再発行可能なトークンではCOLOR識別子の導出にscript_pubkeyを使用するため、Scriptモジュールのparse_from_addrメソッドを用いて生成します。
ColorIdentifierモジュールのreissuableメソッドの引数にscript_pubkeyを指定します。
```ruby
script_pubkey = Tapyrus::Script.parse_from_addr(key_pair.to_p2pkh)
reissuable_color_id = Tapyrus::Color::ColorIdentifier.reissuable(script_pubkey)
puts reissuable_color_id.to_payload.bth
```

実行結果例:
```
c118c00898fe9a4b71fddabf68f671ce54ad439acba9a85be5050cf27ccc727c6d
```


### 再発行不可能なトークン {#generate-color-id-non-reissuable}
txidとindexを元に。[OutPointモジュール](https://github.com/chaintope/tapyrusrb/blob/master/lib/tapyrus/out_point.rb){:target="_blank"}を用いてトランザクションのアウトポイントを生成し、non_reissuableメソッドの引数に指定します。
```ruby
out_point = Tapyrus::OutPoint.from_txid(txid, index)
non_reissuable_color_id = Tapyrus::Color::ColorIdentifier.non_reissuable(out_point)
puts non_reissuable_color_id.to_payload.bth
```

実行結果例:
```
c26dc00eff1382bf20457922fd2fa2b26420b6d7045b28cf5ba90d0ee31055b82b
```

### NFT {#generate-color-id-nft}
NFTも再発行不可能なトークンと同様にOutPointを用いてCOLOR識別子を導出します。
```ruby
out_point = Tapyrus::OutPoint.from_txid(txid, index)
nft_color_id = Tapyrus::Color::ColorIdentifier.nft(out_point)
puts nft_color_id.to_payload.bth
```

実行結果例:
```
c36dc00eff1382bf20457922fd2fa2b26420b6d7045b28cf5ba90d0ee31055b82b
```

サンプルコードは[こちら](https://github.com/chaintope/tapyrus-pages/scripts/tree/master/generate_color_identifer.rb){:target="_blank"}です。

## Scriptの生成 {#generate-script}
次に各種トランザクションに設定するTapyrusスクリプトの生成方法について解説します。
スクリプトの生成には[Scriptモジュール](https://github.com/chaintope/tapyrusrb/blob/master/lib/tapyrus/script/script.rb){:target="_blank"}を使用します。

### P2PKH {#generate-script-p2pkh}
P2PKHはBitcoinと同様のスクリプトを記述します。
```ruby
p2pkh_script = Tapyrus::Script.new << '032ad705d98318241852ba9394a90e85f6afc8f7b5f445675040318a9d9ea29e35' << 
Tapyrus::Script::OP_CHECKSIG
puts p2pkh_script
```

実行結果例:
```
032ad705d98318241852ba9394a90e85f6afc8f7b5f445675040318a9d9ea29e35 OP_CHECKSIG
```

### P2PH {#generate-script-p2sh}
P2PHもBitcoinと同様です。以下は1-of-2マルチシグの例です。
```ruby
key_pair1 = Tapyrus::Key.generate
key_pair2 = Tapyrus::Key.generate
p2sh_script = Tapyrus::Script.new << 1 << key_pair1.to_p2pkh << key_pair2.to_p2pkh << 2 << Tapyrus::Script::OP_CHECKMULTISIG
puts p2sh_script
```

実行結果例:
```
1 63dfb8ddfa2e3fa327686bb44bb31251d0 617117b2e0c2338a03161d47b0f436c434 2 OP_CHECKMULTISIG
```

### CP2PKH {#generate-script-cp2pkh}
CP2PKHにはスクリプトの生成にはScriptモジュールのto_cp2pkhメソッドを用います。
```ruby
txid = '82ef88fbbc7009d5ec8f60a488643c8843e75c3cea5e19a6b9598867689908b7'
index = 1
key_pair = Tapyrus::Key.generate
out_point = Tapyrus::OutPoint.from_txid(txid, index)
nft_color_id = Tapyrus::Color::ColorIdentifier.nft(out_point)
cp2pkh_script = Tapyrus::Script.to_cp2pkh(nft_color_id, key_pair.to_p2pkh)
puts cp2pkh_script
```

実行結果：
```
c36dc00eff1382bf20457922fd2fa2b26420b6d7045b28cf5ba90d0ee31055b82b OP_COLOR OP_DUP OP_HASH160 13afbd331ac0172c623cfa38d123064f5c OP_EQUALVERIFY OP_CHECKSIG
```

### CP2SH {#generate-script-cp2sh}
CP2SHにはスクリプトの生成にはScriptモジュールのto_cp2shメソッドを用います。
```ruby
txid = '82ef88fbbc7009d5ec8f60a488643c8843e75c3cea5e19a6b9598867689908b7'
index = 1
key_pair = Tapyrus::Key.generate
out_point = Tapyrus::OutPoint.from_txid(txid, index)
nft_color_id = Tapyrus::Color::ColorIdentifier.nft(out_point)
cp2sh_script = Tapyrus::Script.to_cp2sh(nft_color_id, key_pair.to_p2pkh)
puts cp2sh_script
```

実行結果例:
```
c36dc00eff1382bf20457922fd2fa2b26420b6d7045b28cf5ba90d0ee31055b82b OP_COLOR OP_HASH160 63dfb8ddfa2e3fa327686bb44bb31251d0 OP_EQUAL
```

### OP_RETURN {#generate-script-opreturn}
OP_RETURNもBitcoinと同様です。
```ruby
op_return_script = Tapyrus::Script.new << Tapyrus::Script::OP_RETURN << "contents".bth
puts op_return_script
```

実行結果例:
```
OP_RETURN 636f6e74656e7473
```

サンプルコードは[こちら](https://github.com/chaintope/tapyrus-pages/scripts/tree/master/generate_script.rb){:target="_blank"}です。

## ScriptInterpreterによるスクリプトの評価 {#scriptInterpreter}
[ScriptInterpreterモジュール](https://github.com/chaintope/tapyrusrb/blob/master/lib/tapyrus/script/script_interpreter.rb){:target="_blank"}を使用します。
```ruby
script_pubkey = Tapyrus::Script.to_p2pkh(key_pair.to_p2pkh)
script_sig = Tapyrus::Script.new << signature << key_pair.pubkey
tx_checker = Tapyrus::TxChecker.new(tx: pay_tx, input_index: 0)
interpreter = Tapyrus::ScriptInterpreter.new(flags: Tapyrus::STANDARD_SCRIPT_VERIFY_FLAGS, checker: tx_checker)
puts interpreter.verify_script(script_sig, script_pubkey)
```

実行するとbooleanで検証結果が出力されます。
```
false
```

サンプルコードは[こちら](https://github.com/chaintope/tapyrus-pages/scripts/tree/master/scriptinterpreter.rb){:target="_blank"}です。