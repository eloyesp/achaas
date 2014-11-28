require 'bundler/setup'
require 'cuba'
require 'achis'
require 'json'

Cuba.define do
  on 'v1' do
    on post do
      json = JSON.parse req.body.read

      unless json['provider']
        res.status = 400
        res.finish
      end

      # send transactions to some provider
      #
      on 'batches' do
        client = Achis::Providers::MockProvider.new
        client.push( json['transactions'] )
        res.write 'ok'
      end
    end
  end
end
