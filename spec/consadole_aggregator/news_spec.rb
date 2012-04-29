# -*- coding: utf-8 -*-
require 'spec_helper'
require 'stringio'

module ConsadoleAggregator
  describe News do
    before do
      ConsadoleAggregator.stub(:logger).and_return(double('logger').as_null_object)
    end

    describe '.register' do
      it { expect {
          described_class.send(:register!) do |sites|
            sites.name(:a_site)
          end
        }.to change { News::Sites.size }.by(1)
      }
    end
  end

  module News
    describe Site do
      before do
        ConsadoleAggregator.stub(:logger).and_return(double('logger').as_null_object)
        described_class.stub_chain(:store, :transaction).and_return(updated)
      end
      let(:updated) { [] }
      subject { described_class.new(:hochiyomiuri) }

      describe '#update' do
        let(:site) {
          site = described_class.new(:hochiyomiuri)
          site.resource = -> { File.read(ext_path('hochiyomiuri.txt')).encode('UTF-8') }
          site.list_parser = ->(list) { Nokogiri::HTML(list).search('div.list1 > ul > li a').reverse }
          site.article_filter = ->(article) { article.text =~ /札幌|コンサ/ }
          site.article_parser = ->(article) { { url: "http://hochi.yomiuri.co.jp#{article['href']}", title: article.text } }
          site
        }
        let(:block) { ->(article) { result << article } }
        let(:result){ [] }

        subject { result }

        describe 'element' do
          before { site.update &block }
          it { subject.first.should include :url, :title }
          it { subject.should satisfy { |list| list.all? { |e| e[:title].include?('札幌') || e[:title].include?('コンサ') } } }
        end

        describe 'updated' do
          before { site.update &block }
          it { updated.should_not be_empty }
        end

        context 'when have updated item' do
          before { site.update &block }
          let(:updated) {
            resource = File.read(ext_path('hochiyomiuri.txt')).encode('UTF-8')
            Nokogiri::HTML(resource).search('div.list1 > ul > li a').reverse.slice(0...-1).map { |i|
              { url: "http://hochi.yomiuri.co.jp#{i['href']}", title: i.text }
            }
          }
          it { subject.should have(1).item }
        end

        context 'when raise error on get resource' do
          before { Net::HTTP.stub(:get).and_return { raise } }
          it { expect { site.update &block }.not_to raise_error }
        end

        context 'when raise error on block' do
          before { site.update &block }
          let(:block) {
            error_occured = false
            ->(article) {
              unless error_occured
                error_occured = true
                raise
              end
              result << article
            }
          }
          it { expect { site.update &block }.not_to raise_error }
          it { subject.should_not be_empty }
        end
      end
    end
  end
end
