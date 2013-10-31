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
# This example gets all custom channels an ad unit has been added to.
#
# To get ad clients, run get_all_ad_clients.rb. To get ad units, run
# get_all_ad_units.rb.
#
# Tags: accounts.adunits.customchannels.list

require 'adexchangeseller_common'

# The maximum number of results to be returned in a page.
MAX_PAGE_SIZE = 50

def get_all_custom_channels_for_ad_unit(adexchangeseller, account_id,
                                        ad_client_id, ad_unit_id)

  request = adexchangeseller.accounts.adunits.customchannels.list(
    :accountId => account_id,
    :adClientId => ad_client_id,
    :adUnitId => ad_unit_id,
    :maxResults => MAX_PAGE_SIZE
  )

  loop do
    result = request.execute

    result.data.items.each do |custom_channel|
      puts 'Custom channel with code "%s" and name "%s" was found.' %
        [custom_channel.code, custom_channel.name]

      if custom_channel['targetingInfo']
        puts '  Targeting info:'
        targeting_info = custom_channel.targetingInfo
        if targeting_info['adsAppearOn']
          puts '    Ads appear on: %s' % targeting_info.adsAppearOn
        end
        if targeting_info['location']
          puts '    Location: %s' % targeting_info.location
        end
        if targeting_info['description']
          puts '    Description: %s' % targeting_info.description
        end
        if targeting_info['siteLanguage']
          puts '    Site language: %s' % targeting_info.siteLanguage
        end
      end
    end

    break unless result.next_page_token
    request = result.next_page
  end
end


if __FILE__ == $0
  adexchangeseller = service_setup()

  unless ARGV.size == 3
    puts "Usage: #{$0} ACCOUNT_ID AD_CLIENT_ID AD_UNIT_ID"
    exit
  end

  account_id, ad_client_id, ad_unit_id = ARGV

  get_all_custom_channels_for_ad_unit(
    adexchangeseller, account_id, ad_client_id, ad_unit_id)
end
