$: << 'lib'

require 'consadole_aggregator'
require 'oauth'
require 'rubytter'

include ConsadoleAggregator::Entry

ACCOUNT = YAML.load_file('account.yaml')
oauth = Rubytter::OAuth.new(ACCOUNT['consumer']['key'], ACCOUNT['consumer']['secret'])
access_token = OAuth::AccessToken.new(oauth.create_consumer, ACCOUNT['access']['key'], ACCOUNT['access']['secret'])
t = OAuthRubytter.new(access_token)

[
 NikkanSports.new,
 HochiYomiuri.new,
 Asahi.new,
 ForzaConsadole.new,
 ConsaBurn.new,
 ConsaClub.new,
 ConsadoleNews.new,
 ConsadoleSponsorNews.new,
 ConsadolePhotos.new,
 JsGoalNews.new,
 JsGoalPhoto.new
].each do |items|
  items.new_items.each do |item|
    t.update "#{ConsadoleAggregator.truncate(item.title, item.uri)} #consadole"
    item.save
  end
end
