#!/usr/bin/env ruby

require_relative '../lib/redis-insights'

require 'clockwork'
require 'trollop'

opts = Trollop::options do 
  opt :redis_url, 'redis connect string', type: String, default: 'redis://localhost:6379', short: '-s'
  opt :insights_event_url, 'New Relic Insights custom event URL', type: String, required: true, short: '-u'
  opt :insights_insert_key, 'Insights Insert API Key', type: String, required: true, short: '-k'
  opt :report_frequency, 'Frequency of INFO query and event insertion', type: Integer, required: false, default: 60, short: '-f'
  opt :insights_event_type, 'Type field for the Insights event', type: String, short: '-t', default: 'RedisInfo'
end

redis_insights = RedisInsights.new(opts[:redis_url], 
                                   opts[:insights_event_url],
                                   opts[:insights_insert_key],
                                   opts[:insights_event_type])

module Clockwork
  every opts[:report_frequency].seconds, 'pull redis INFO and post to Insights' do
    redis_insights.info_to_insights
  end
end

Clockwork::run
