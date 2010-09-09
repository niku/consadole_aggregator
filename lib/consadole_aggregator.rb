# -*- coding: utf-8 -*-
require 'oauth'
require 'rubytter'
require 'consadole_aggregator/entry.rb'

module ConsadoleAggregator
  def self.truncate str, url
    if str.size > 110
      "#{str[0...107]}... #{url}"
    else
      "#{str} #{url}"
    end
  end
end

if __FILE__==$0
  ACCOUNT = YAML.load_file('account.yaml')
  oauth = Rubytter::OAuth.new(ACCOUNT['consumer']['key'], ACCOUNT['consumer']['secret'])
  access_token = OAuth::AccessToken.new(oauth.create_consumer, ACCOUNT['access']['key'], ACCOUNT['access']['secret'])
  t = OAuthRubytter.new(access_token)

  [
   ConsadoleAggregator::NikkanSports.new,
   ConsadoleAggregator::HochiYomiuri.new,
   ConsadoleAggregator::Asahi.new,
   ConsadoleAggregator::ForzaConsadole.new,
   ConsadoleAggregator::ConsaBurn.new,
   ConsadoleAggregator::ConsaClub.new,
   ConsadoleAggregator::ConsadoleNews.new,
   ConsadoleAggregator::ConsadoleSponsorNews.new,
   ConsadoleAggregator::ConsadolePhotos.new,
   ConsadoleAggregator::JsGoalNews.new,
   ConsadoleAggregator::JsGoalPhoto.new
  ].each do |items|
    items.new_items.each do |item|
      t.update "#{ConsadoleAggregator.truncate(item.title, item.uri)} #consadole"
      item.save
    end
  end
end
