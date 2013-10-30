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
# This example gets a specific account for the logged in user.
# This includes the full tree of sub-accounts.
#
# Tags: accounts.get

require 'adsense_common'

# The maximum number of results to be returned in a page.
MAX_PAGE_SIZE = 50

def get_account_tree(adsense, account_id)
  result = adsense.accounts.list(
    :accountId => account_id,
    :maxResults => MAX_PAGE_SIZE
  ).execute

  display_tree(result.data.items.first) if result.data && result.data.items
end

def display_tree(account, level = 0)
  puts ('  ' * level) + ('Account with ID "%s" and name "%s" was found. ' %
    [account.id, account.name])

  if account['subAccounts'] && !account['subAccounts'].empty?
    account.subAccounts.each do |sub_account|
      display_tree(sub_account, level + 1)
    end
  end
end


if __FILE__ == $0
  adsense = service_setup()

  unless ARGV.size == 1
    puts "Usage: #{$0} ACCOUNT_ID"
    exit
  end

  account_id = ARGV.first

  get_account_tree(adsense, account_id)
end
