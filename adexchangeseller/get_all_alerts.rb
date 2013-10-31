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
# Gets all alerts available for the logged in user's account.
#
# Tags: alerts.list

require 'adexchangeseller_common'

# The maximum number of results to be returned in a page.
MAX_PAGE_SIZE = 50

def get_all_alerts(adexchangeseller)
  request = adexchangeseller.alerts.list(:maxResults => MAX_PAGE_SIZE)

  loop do
    result = request.execute

    result.data.items.each do |alert|
      puts 'Alert id "%s" with severity "%s" and type "%s" was found.'  %
        [alert.id, alert.severity, alert.type]
    end

    break unless result.next_page_token
    request = result.next_page
  end
end


if __FILE__ == $0
  adexchangeseller = service_setup()
  get_all_alerts(adexchangeseller)
end
