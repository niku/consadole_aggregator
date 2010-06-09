# -*- coding: utf-8 -*-
require 'oauth'
require 'rubytter'
require 'consadole_aggregator/entry.rb'

module ConsadoleAggregator
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
      text = "#{item.title} #{item.uri} #consadole"
      if text.size > 140
        truncate_size = text.size - 140 + '...'.size
        text = "#{item.title[0...-truncate_size]}... #{item.uri} #consadole"
      end
      t.update text
      item.save
    end
  end
end
