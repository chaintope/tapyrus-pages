require 'tapyrus'

Tapyrus.chain_params = :dev

key_pair = Tapyrus::Secp256k1::Ruby.generate_key
puts "秘密鍵(WIF): #{Tapyrus::Key.new(priv_key: key_pair.priv_key).to_wif}"
puts "公開鍵： #{key_pair.pubkey}"