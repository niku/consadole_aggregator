$: << 'lib'

require 'consadole_aggregator'
require 'oauth'
require 'rubytter'

include ConsadoleAggregator

ACCOUNT = YAML.load_file('account.yaml')
oauth = Rubytter::OAuth.new(ACCOUNT['consumer']['key'], ACCOUNT['consumer']['secret'])
access_token = OAuth::AccessToken.new(oauth.create_consumer, ACCOUNT['access']['key'], ACCOUNT['access']['secret'])
t = OAuthRubytter.new(access_token)

Live.reserve(Time.parse(ARGV[0])).execute do |timeline|
  t.update Helper.concat(timeline, '', '#consadole')
end
