require 'grape'

class Achaas < Grape::API
  version 'v1'
  resource :batches do
    desc 'send transactions to some provider'
    params do
      requires :provider
    end
    post do
      'ok'
    end
  end
end
