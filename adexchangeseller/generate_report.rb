#!/usr/bin/env ruby
# Encoding: utf-8
#
# Author:: sgomes@google.com (Sérgio Gomes)
#
# Copyright:: Copyright 2013, Google Inc. All Rights Reserved.
#
# License:: Licensed under the Apache License, Version 2.0 (the "License");
#           you may not use this file except in compliance with the License.
#           You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#           Unless required by applicable law or agreed to in writing, software
#           distributed under the License is distributed on an "AS IS" BASIS,
#           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#           implied.
#           See the License for the specific language governing permissions and
#           limitations under the License.
#
# Retrieves a saved report or a report for the specified ad client.
#
# To get ad clients, run get_all_ad_clients.rb.
#
# Tags: reports.generate, reports.saved.generate

require 'adexchangeseller_common'
require 'optparse'

def generate_report(adexchangeseller, options)
  ad_client_id = options[:ad_client_id]
  saved_report_id = options[:report_id]

  result = nil
  if saved_report_id
    # Generate a report from a saved report ID.
    result = adexchangeseller.reports.saved.generate(
      :savedReportId => saved_report_id
    ).execute
  else
    # Generate a new report for the provided ad client ID.
    result = adexchangeseller.reports.generate(
      :startDate => '2011-01-01',
      :filter => ['AD_CLIENT_ID==' + ad_client_id],
      :endDate => '2011-08-31',
      :metric => ['PAGE_VIEWS', 'AD_REQUESTS', 'AD_REQUESTS_COVERAGE',
                  'CLICKS', 'AD_REQUESTS_CTR', 'COST_PER_CLICK',
                  'AD_REQUESTS_RPM', 'EARNINGS'],
      :dimension => ['DATE'],
      :sort => ['+DATE']
    ).execute
  end

  # Display headers.
  result.data.headers.each do |header|
    print '%25s' % header['name']
  end
  puts

  # Display results.
  result.data.rows.each do |row|
    row.each do |column|
      print '%25s' % column
    end
    puts
  end
end


if __FILE__ == $0
  adexchangeseller = service_setup()

  options = {}

  optparse = OptionParser.new do |opts|
    opts.on('-c', '--ad_client_id AD_CLIENT_ID',
            'The ID of the ad client for which to generate a report') do |id|
      options[:ad_client_id] = id
    end

    opts.on('-r', '--report_id REPORT_ID',
            'The ID of the saved report to generate') do |id|
      options[:report_id] = id
    end
  end

  begin
    optparse.parse!
    unless options[:ad_client_id].nil? ^ options[:report_id].nil?
      raise OptionParser::MissingArgument
    end
  rescue OptionParser::MissingArgument
    puts 'Please specify either ad_client_id or report_id.'
    puts optparse
    exit
  rescue OptionParser::InvalidOption
    puts optparse
    exit
  end

  generate_report(adexchangeseller, options)
end
