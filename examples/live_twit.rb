$: << 'lib'

require 'consadole_aggregator'
require 'oauth'
require 'rubytter'

include ConsadoleAggregator::Live

ACCOUNT = YAML.load_file('account.yaml')
oauth = Rubytter::OAuth.new(ACCOUNT['consumer']['key'], ACCOUNT['consumer']['secret'])
access_token = OAuth::AccessToken.new(oauth.create_consumer, ACCOUNT['access']['key'], ACCOUNT['access']['secret'])
t = OAuthRubytter.new(access_token)

live = Live.new

fork do
  fork do
    begin
      wait_second = Live.sleeptime(Time.parse(ARGV[0]))
      puts "wait #{wait_second} seconds"
      sleep wait_second
    rescue
      puts $!
    end

    120.times do
      puts Time.now
      begin
        live.new_timeline(Live.parse(Live::BASE_URI)).each do |timeline|
          text = timeline.time + ' ' + timeline.post
          puts "#{ConsadoleAggregator.truncate(text)} #consadole"
          t.update "#{ConsadoleAggregator.truncate(text)} #consadole"
          live.add_timeline(timeline)
        end
      rescue
        puts $!
      end
      sleep 60
    end
  end
end
