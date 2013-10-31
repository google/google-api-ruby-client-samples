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
# Gets all preferred deals for the logged in user's account.
#
# Tags: preferreddeals.list

require 'adexchangeseller_common'

# The maximum number of results to be returned in a page.
MAX_PAGE_SIZE = 50

def get_all_alerts(adexchangeseller)
  request = adexchangeseller.preferreddeals.list(:maxResults => MAX_PAGE_SIZE)

  loop do
    result = request.execute

    result.data.items.each do |deal|
      output = 'Deal id "%s" ' % deal['id']

      if deal['advertiserName']
        output += 'for advertiser "%s" ' % deal['advertiserName']
      end

      if deal['buyerNetworkName']
        output += 'on network "%s" ' % deal['buyerNetworkName']
      end

      output += 'was found.'
      puts output
    end

    break unless result.next_page_token
    request = result.next_page
  end
end


if __FILE__ == $0
  adexchangeseller = service_setup()
  get_all_alerts(adexchangeseller)
end
