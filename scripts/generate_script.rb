require 'tapyrus'

### p2pkh
key_pair1 = Tapyrus::Key.generate
p2pkh_script = Tapyrus::Script.to_p2pkh(Tapyrus.hash160(key_pair1.pubkey))
puts "p2pkh_script: #{p2pkh_script}"


### p2sh
key_pair1 = Tapyrus::Key.generate
key_pair2 = Tapyrus::Key.generate
p2sh_script = Tapyrus::Script.new << 1 << key_pair1.to_p2pkh << key_pair2.to_p2pkh << 2 << Tapyrus::Script::OP_CHECKMULTISIG
puts "p2sh_script: #{p2sh_script.to_p2sh}"


### cp2pkh
txid = '82ef88fbbc7009d5ec8f60a488643c8843e75c3cea5e19a6b9598867689908b7'
index = 1
out_point = Tapyrus::OutPoint.from_txid(txid, index)
out_point = Tapyrus::OutPoint.from_txid(txid, index)
non_reissuable_color_id = Tapyrus::Color::ColorIdentifier.non_reissuable(out_point)
nft_color_id = Tapyrus::Color::ColorIdentifier.nft(out_point)
cp2pkh_script = Tapyrus::Script.to_cp2sh(nft_color_id, key_pair1.to_p2pkh)
puts "cp2pkh_script: #{cp2pkh_script}"


### cp2sh
txid = '82ef88fbbc7009d5ec8f60a488643c8843e75c3cea5e19a6b9598867689908b7'
index = 1
out_point = Tapyrus::OutPoint.from_txid(txid, index)
non_reissuable_color_id = Tapyrus::Color::ColorIdentifier.non_reissuable(out_point)
nft_color_id = Tapyrus::Color::ColorIdentifier.nft(out_point)
cp2sh_script = Tapyrus::Script.to_cp2sh(nft_color_id, key_pair1.to_p2pkh)
puts "cp2sh_script: #{cp2sh_script}"

### OP_RETURN
op_return_script = Tapyrus::Script.new << Tapyrus::Script::OP_RETURN << "contents".bth
puts "op_return_script: #{op_return_script}"