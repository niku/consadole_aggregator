# -*- coding: utf-8 -*-
require 'spec_helper'
require 'time'

module ConsadoleAggregator
  describe Live do
    before do
        ConsadoleAggregator.stub(:logger).and_return(double('logger').as_null_object)
    end
    let(:document) { File.read(ext_path('live/s674.html.120')).force_encoding('SJIS') }

    describe ".parse" do
      it { described_class.parse(document).should have(69).items }
      it { described_class.parse(document).first.should eq '試合開始 札幌ボールでキックオフ' }
      it { described_class.parse(document).last.should be_include '試合終了' }
    end

    describe ".fetch" do
      context "when HTTP.get success" do
        before { Net::HTTP.stub(:get).and_return(document) }
        it { described_class.fetch.should have_at_least(1).items }
      end

      context "when HTTP.get failure" do
        before { Net::HTTP.stub(:get).and_raise("can't get") }
        it { described_class.fetch.should have(0).items }
      end
    end

    describe "#update" do
      let(:fetched) {
        [
         '試合開始 札幌ボールでキックオフ',
         '1分 【札幌先制GOAL!】',
         '2分 【札幌GOAL!】'
        ]
      }
      before do
        described_class.stub(:fetch).and_return(fetched)
        subject.send(:posted) << fetched.first
      end

      it 'when first called raise error,other times don\'t raise error' do
        result = []
        called = false
        subject.update { |post|
          if called
            result << post
          else
            called = true
            raise
          end
        }
        result.should eq [{ title: fetched.last}]
      end
    end

    describe ".run" do
      let(:runner) { double('runner').as_null_object }
      let(:starting_time) { Time.parse('2012-04-07 20:48') }
      let(:option) {
        {
          length_of_a_game: 180,
          interval: 30,
          daemonize: false
        }
      }
      subject { described_class.run starting_time, option }
      before do
        Live::Runner.stub(:new).and_return(runner)
      end

      it {
        runner.should_receive(:length_of_a_game=).with(180)
        subject
      }

      it {
        runner.should_receive(:interval=).with(30)
        subject
      }

      it {
        runner.should_receive(:daemonize=).with(false)
        subject
      }
    end
  end
end
