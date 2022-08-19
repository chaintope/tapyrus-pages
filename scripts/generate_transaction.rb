require 'tapyrus'

utxo = {
  script_pubkey: "76a914426b371b81a6da4b5ee616de7f7328b36fb813ec88ac",
  txid: '5da116c8b9f6b85fb8ff26428ddf2d71cb1cb230a4ea6767759cebe9045616f0',
  index: 0,
  value: 3_000
}

### 送金トランザクションの作成
key_pair = Tapyrus::Key.generate
tx_builder = Tapyrus::TxBuilder.new.fee(1_000) 
pay_tx = tx_builder.add_utxo(utxo).change_address(key_pair.to_p2pkh).pay(key_pair.to_p2pkh, 1_000).build
puts "トランザクションID: #{pay_tx.txid}"
puts "未署名の送金トランザクション(hex): #{pay_tx.to_hex}"


### 再発行可能なトークン発行トランザクションの作成
key_pair = Tapyrus::Key.generate
tx_builder = Tapyrus::TxBuilder.new.fee(1_000) 
non_reissuable_tx = tx_builder.add_utxo(utxo).non_reissuable(Tapyrus::OutPoint.from_txid(utxo[:txid], utxo[:index]), key_pair.to_p2pkh, 10_000).build
puts "トランザクションID: #{non_reissuable_tx.txid}"
puts "未署名の再発行可能なトークン発行トランザクション(hex): #{non_reissuable_tx.to_hex}"


### 再発行不可能なトークン発行トランザクションの作成
key_pair = Tapyrus::Key.generate
tx_builder = Tapyrus::TxBuilder.new.fee(1_000) 
non_reissuable_tx = tx_builder.add_utxo(utxo).non_reissuable(Tapyrus::OutPoint.from_txid(utxo[:txid], utxo[:index]), key_pair.to_p2pkh, 10_000).build
puts "トランザクションID: #{non_reissuable_tx.txid}"
puts "未署名のNFT発行トランザクション(hex): #{non_reissuable_tx.to_hex}"


### NFT発行トランザクションの作成
key_pair = Tapyrus::Key.generate
tx_builder = Tapyrus::TxBuilder.new.fee(1_000) 
nft_tx = tx_builder.add_utxo(utxo).nft(Tapyrus::OutPoint.from_txid(utxo[:txid], utxo[:index]), key_pair.to_p2pkh).build
puts "トランザクションID: #{nft_tx.txid}"
puts "未署名のNFT発行トランザクション(hex): #{nft_tx.to_hex}"


### 署名
sig_hash = pay_tx.sighash_for_input(utxo[:index], Tapyrus::Script.parse_from_payload(utxo[:script_pubkey]))
signature = key_pair.sign(sig_hash) + [Tapyrus::SIGHASH_TYPE[:all]].pack('C')
pay_tx.in[0].script_sig << signature
pay_tx.in[0].script_sig << key_pair.pubkey.htb
puts "トランザクションID: #{pay_tx.txid}"
puts "署名後の送金トランザクション(hex): #{pay_tx.to_hex}"