require 'google/api_client'
require '../oauth/oauth_util'

# Create a new API client & load the Google+ API 
client = Google::APIClient.new
plus = client.discovered_api('plus', 'v1')

auth_util = CommandLineOAuthHelper.new('https://www.googleapis.com/auth/plus.me')
client.authorization = auth_util.authorize()

# Get & print the activities for the authorized user
result = client.execute(
  :api_method => plus.activities.list,
  :parameters => {
    'userId' => 'me',
    'collection' => 'public'
  })

result.data.items.each do |item|
   print "ID #{item.id} - #{item.object.content}\n" 
end
