require 'bundler/setup'
require 'grape'
require 'achis'

class Achaas < Grape::API
  version 'v1'

  resource :batches do
    desc 'send transactions to some provider'
    params do
      requires :provider
    end
    post do
      client = Achis::Providers::MockProvider.new
      client.push( params['transactions'] )
      'ok'
    end
  end
end
