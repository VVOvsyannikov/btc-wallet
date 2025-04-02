# frozen_string_literal: true

def utxos
  [
    {
      'txid' => '7a6cd8404a8daf0e0e9d32789f30e90fb9845ce56e118ca1df27c0257848d746',
      'vout' => 0,
      'value' => 100_000,
      'status' => {
        'confirmed' => true
      }
    },
    {
      'txid' => '8b7cd8404a8daf0e0e9d32789f30e90fb9845ce56e118ca1df27c0257848d747',
      'vout' => 1,
      'value' => 200_000,
      'status' => {
        'confirmed' => false
      }
    }
  ]
end

def balance_message
  <<~INFO
    Address: tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx
    Confirmed Balance: 100000 satoshis (0.001 BTC)
    Pending Balance: 200000 satoshis (0.002 BTC)
    Total Balance: 300000 satoshis (0.003 BTC)
  INFO
end

def wrong_message
  ['Something went wrong, please, try later']
end

def response
  'Transaction broadcasted some_tx_id'
end

def valid_address
  'bc1qw508d6qejxtdg4y5r3zarvaryvaxxpcsdkxyen'
end

def invalid_address
  nil
end
