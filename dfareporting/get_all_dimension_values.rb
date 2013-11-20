# This example illustrates how to list all values for a dimension
require './dfareporting_utils'

args = DfaReportingUtils.get_arguments(ARGV, 'profile_id')

client, dfareporting = DfaReportingUtils.setup()

# Create the dimension to query
dimension = {
  :dimensionName => 'dfa:advertiser',
  :startDate => '2013-01-01',
  :endDate => '2013-12-31'
}

# Get all report files
result = client.execute(
  :api_method => dfareporting.dimension_values.query,
  :body_object => dimension,
  :parameters => {
    :profileId => args['profile_id']
  })
      
while not result.nil? do
  # Display results.
  puts result.body
  
  token = result.data.next_page_token
  
  if token.nil? or token.empty? or token == '0'
    result = nil
  else
    result = client.execute(
      :api_method => dfareporting.dimension_values.query,
      :body_object => dimension,
      :parameters => {
        :profileId => args['profile_id']
      })
  end
end
