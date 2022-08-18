require 'tapyrus'

### createwallet
config =  { schema: 'http', host: 'localhost', port: 12381, user: 'user', password: 'pass' }
client = Tapyrus::RPC::TapyrusCoreClient.new(config)
puts client.createwallet("rbtest")

### listunspent
config =  { schema: 'http', host: 'localhost', port: 12381, user: 'user', password: 'pass', wallet: "rbtest" }
client = Tapyrus::RPC::TapyrusCoreClient.new(config)
puts client.listunspent