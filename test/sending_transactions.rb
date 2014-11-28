require 'rack/test'

include Rack::Test::Methods

def app
  Achaas
end

test 'POST /v1/transactions' do
  post '/v1/transactions', <<-JSON
    {
        "id": "FD00AFA8A0F7",
        "transaction_type": "debit",
        "amount": "16",
        "effective_date": "2013-03-26",
        "first_name": "marge",
        "last_name": "baker",
        "address": "101 2nd st",
        "city": "wellsville",
        "state": "KS",
        "postal_code": "66092",
        "telephone": "5858232966",
        "account_type": "checking",
        "routing_number": "103100195",
        "account_number": "3423423253234"
    }
  JSON
  assert last_response.successful?
end
