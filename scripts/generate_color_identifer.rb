require 'tapyrus'

txid = '82ef88fbbc7009d5ec8f60a488643c8843e75c3cea5e19a6b9598867689908b7'
index = 1
key_pair = Tapyrus::Key.generate

### 再発行可能なトークン
script_pubkey = Tapyrus::Script.parse_from_addr(key_pair.to_p2pkh)
reissuable_color_id = Tapyrus::Color::ColorIdentifier.reissuable(script_pubkey)
puts "reissuable_color_id: #{reissuable_color_id.to_payload.bth}"

### 再発行不可能なトークン
out_point = Tapyrus::OutPoint.from_txid(txid, index)
non_reissuable_color_id = Tapyrus::Color::ColorIdentifier.non_reissuable(out_point)
puts "non_reissuable_color_id: #{non_reissuable_color_id.to_payload.bth}"

### NFT
nft_color_id = Tapyrus::Color::ColorIdentifier.nft(out_point)
puts "nft_color_id: #{nft_color_id.to_payload.bth}"