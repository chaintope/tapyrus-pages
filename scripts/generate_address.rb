require 'tapyrus'

Tapyrus.chain_params = :prod
key_pair = Tapyrus::Key.generate

puts "秘密鍵(WIF): #{key_pair.to_wif}"
puts "アドレス: #{key_pair.to_p2pkh}"
