# Copyright (C) 2013 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This example illustrates how to list all user profiles
require './dfareporting_utils'

# Authenticate
client, dfareporting = DfaReportingUtils.setup()

# Get all user profiles
result = client.execute(
    :api_method => dfareporting.user_profiles.list)  
        
# Display results.
puts result.body
