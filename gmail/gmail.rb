require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'

client = Google::APIClient.new(
  application_name: 'Pms file retrieval',
  application_version: '1.0.0',
)

# Here, you need to set the access and refresh token from your account
user_credentials = {
  access_token: 'access_token',
  token_type: 'Bearer',
  expires_in: 3600,
  refresh_token: 'refresh_token',
}

# Load client secrets from your client_secrets.json.
client_secrets = Google::APIClient::ClientSecrets.load
client.authorization = client_secrets.to_authorization
client.authorization.scope = 'https://mail.google.com/'
client.authorization.update_token!(user_credentials)

# Get a new access_token
request_parameters = {
  refresh_token: user_credentials[:refresh_token],
  client_id: client_secrets.client_id,
  client_secret: client_secrets.client_secret,
  grant_type: 'refresh_token',
}
url = 'https://accounts.google.com/o/oauth2/token'
uri = URI.parse(url)
response = Net::HTTP.post_form(uri, request_parameters)
user_credentials[:access_token] = JSON.load(response.body)['access_token']
client.authorization.update_token!(user_credentials)

# load gmail API
gmail = client.discovered_api('gmail', 'v1')

# Get list of labels
labels_result = client.execute(
  api_method: gmail.users.labels.list,
  parameters: { userId: 'me' },
  authorization: client.authorization,
)
labels = {}
JSON.load(labels_result.body)['labels'].each do |x|
  labels[x['id']] = x['name']
end

# Iterate through labels
labels.each do |_, label_name|
  emails = nil
  next_page_token = nil
  # One request returns max 100 mails, so we iterate while there is a nextPageToken
  while !next_page_token.nil? || emails.nil?
    emails ||= []
    # Retrieve all unread mail in the current label
    emails_result = client.execute(
      api_method: gmail.users.messages.list,
      parameters: {
        userId: 'me',
        maxResults: 100,
        q: "is:unread label:#{label_name}",
        pageToken: next_page_token,
      },
      authorization: client.authorization,
    )
    result = JSON.load(emails_result.body)
    next_page_token = result['nextPageToken']
    emails.append(result['messages'].map { |x| x['id'] }) unless result['messages'].nil?
  end
  emails.flatten!
  # emails is now an array of email ids
  next if emails.size == 0

  # Iterate through mails
  emails.each do |id|
    email_result = client.execute(
      api_method: gmail.users.messages.get,
      parameters: {
        userId: 'me',
        id: id,
      },
      authorization: client.authorization,
    )
    email = JSON.load(email_result.body)
    headers = {}
    email['payload']['headers'].each { |x| headers[x['name']] = x['value'] }
    received_at = headers['Date'].to_datetime

    # Mark mail as read if older than 2 days
    if (DateTime.now.utc - 2.days) > received_at
      client.execute(
        api_method: gmail.users.messages.modify,
        parameters: {
          userId: 'me',
          id: id,
        },
        body_object: {
          removeLabelIds: ['UNREAD'],
          addLabelIds: [skipped_too_old],
        },
        authorization: client.authorization,
      )
      next
    end

    # Extensions of attachments to retrieve from mails
    extensions = %w(xls xlsx)

    # Find attachments
    email['payload']['parts'].each do |part|
      next if part['filename'].nil?
      next unless part['filename'].include? '.'
      extension = part['filename'].split('.').last.downcase
      next unless extensions.include? extension
      filepath = Rails.root.join(part['filename'])
      file = File.new(filepath, 'w+b')
      attachment_result = client.execute(
        api_method: gmail.users.messages.attachments.get,
        parameters: {
          userId: 'me',
          messageId: id,
          id: part['body']['attachmentId'],
        },
        authorization: client.authorization,
      )
      # Write attachment into file
      file << Base64.urlsafe_decode64(JSON.load(attachment_result.body)['data'])
      file.close
    end
    # Mark mail as read
    client.execute(
      api_method: gmail.users.messages.modify,
      parameters: {
        userId: 'me',
        id: id,
      },
      body_object: { removeLabelIds: ['UNREAD'] },
      authorization: client.authorization,
    )
    # Send a confirmation to the expeditor that the mail has been read correctly
    msg = Mail.new do
      date Time.now
      subject 'Attachment received correctly'
      from 'me@gmail.com'
      to headers['From']
      cc 'copy@gmail.com'
      reply_to 'my_other_address@gmail.com'
      html_part do
        body 'Hi,<br /><br />I can use html in this body'
      end
    end
    client.execute(
      api_method: gmail.users.messages.to_h['gmail.users.messages.send'],
      parameters: { userId: 'me' },
      body_object: { raw: Base64.urlsafe_encode64(msg.to_s) },
    )
  end
end
