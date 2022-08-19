require 'tapyrus'

key_pair = Tapyrus::Key.generate
puts "秘密鍵(WIF): #{key_pair.to_wif}"
puts "公開鍵： #{key_pair.pubkey}"
puts "アドレス: #{key_pair.to_p2pkh}"