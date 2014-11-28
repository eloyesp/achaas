require 'rack/test'
require 'pp'
require 'achis/mock_connection'

include Rack::Test::Methods

I18n.enforce_available_locales = false

prepare do
  header 'Content-Type', 'application/json'
end

prepare do
  Achis::MockConnection.teardown_mocks
end

def app
  Achaas
end

class Achis::Providers::MockProvider < Achis::Client

  self.connection_adapter_class = Achis::MockConnection

  def provider_name
   'mock_provider'
  end

  def connection_settings
    []
  end

  def returns_path
    '/returns'
  end

  def returns_files_pattern(date)
    "sample_return-#{ date.strftime('%Y-%m-%d') }.*.csv"
  end

  def parse_returns returns_file
    File.read(returns_file).chomp.split(',').map do |transaction|
      {
        transaction_id: 'sample',
        nacha_code:     transaction.downcase,
        date:           Date.new(2014, 10, 12),
        description:    'a sample return'
      }
    end
  end

  def file_name
    'transactions.csv'
  end

  def batch_file_contents batch
    batch.map do |transaction|
      [ transaction.id, transaction.amount ]
    end.join("\n")
  end

  def push_remote_file_path
    '/inbox'
  end

end

def assert bool, *rest
  pp last_response unless bool
  super
end

test 'POST /v1/batches' do
  post '/v1/batches', <<-JSON
    {
        "provider": "mock_provider",
        "transactions": [
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
        ]
    }
  JSON
  assert last_response.successful?
end

test 'a provider needs to be passed' do
  post '/v1/batches', <<-JSON
    {
        "transactions": [
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
        ]
    }
  JSON
  assert last_response.bad_request?
end

test 'it send the transactions to the provider' do
  assert Achis::MockConnection.sent_files.empty?
  post '/v1/batches', <<-JSON
    {
        "provider": "mock_provider",
        "transactions": [
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
        ]
    }
  JSON
  assert !Achis::MockConnection.sent_files.empty?
end
