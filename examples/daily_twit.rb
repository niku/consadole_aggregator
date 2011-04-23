$: << 'lib'

require 'consadole_aggregator'
require 'oauth'
require 'rubytter'

include ConsadoleAggregator

LOGGER = Logger.new('log/consadole_news.log')
ACCOUNT = YAML.load_file('account.yaml')
oauth = Rubytter::OAuth.new(ACCOUNT['consumer']['key'], ACCOUNT['consumer']['secret'])
access_token = OAuth::AccessToken.new(oauth.create_consumer, ACCOUNT['access']['key'], ACCOUNT['access']['secret'])
t = OAuthRubytter.new(access_token)

[
 News::Nikkansports.new,
 News::Hochiyomiuri.new,
 News::Asahi.new,
 News::Forzaconsadole.new,
 News::Consaburn.new,
 News::Consaclub.new,
 News::Consadolenews.new,
 News::Consadolesponsornews.new,
 News::Consadolephotos.new,
 News::Jsgoalnews.new,
 News::Jsgoalphotos.new
].each { |news|
  news.update{ |article|
    status = Helper.concat(article[:title], article[:url], '#consadole')
    t.update status
  }
}
