require 'tapyrus'

utxo = {
  script_pubkey: "76a914426b371b81a6da4b5ee616de7f7328b36fb813ec88ac",
  txid: '5da116c8b9f6b85fb8ff26428ddf2d71cb1cb230a4ea6767759cebe9045616f0',
  index: 0,
  value: 3_000
}

## 送金トランザクションの作成
key_pair = Tapyrus::Key.generate
tx_builder = Tapyrus::TxBuilder.new.fee(1_000) 
pay_tx = tx_builder.add_utxo(utxo).change_address(key_pair.to_p2pkh).pay(key_pair.to_p2pkh, 1_000).build

## 署名
sig_hash = pay_tx.sighash_for_input(utxo[:index], Tapyrus::Script.parse_from_payload(utxo[:script_pubkey]))
signature = key_pair.sign(sig_hash) + [Tapyrus::SIGHASH_TYPE[:all]].pack('C')
pay_tx.in[0].script_sig << signature
pay_tx.in[0].script_sig << key_pair.pubkey.htb

## ScriptInterpreterによるスクリプトの評価
script_pubkey = Tapyrus::Script.to_p2pkh(key_pair.to_p2pkh)
script_sig = Tapyrus::Script.new << signature << key_pair.pubkey
tx_checker = Tapyrus::TxChecker.new(tx: pay_tx, input_index: 0)
interpreter = Tapyrus::ScriptInterpreter.new(flags: Tapyrus::STANDARD_SCRIPT_VERIFY_FLAGS, checker: tx_checker)
puts interpreter.verify_script(script_sig, script_pubkey)


