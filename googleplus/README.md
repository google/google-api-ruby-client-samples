# Google+ Ruby Sample

This is a simple Sinatra web application that calls the Google+ APIs in ruby.

## Prerequisites

Please make sure that you're running Ruby 1.8.7+ and you've run
`bundle install` on the sample to install all prerequisites.

## Setup Authentication

This API uses OAuth 2.0. Learn more about Google APIs and OAuth 2.0 here:
https://developers.google.com/accounts/docs/OAuth2

Or, if you'd like to dive right in, follow these steps.

- Visit https://console.developers.google.com/start/api?id=plus to create or select a project in the Google Developers Console and automatically turn on the API. Click Continue, then Go to credentials.
- At the top of the page, select the OAuth consent screen tab. Select an Email address, enter a Product name if not already set, and click the Save button.
- Select the Credentials tab, click the Add credentials button and select OAuth 2.0 client ID.
- Select the application type Other, enter the name "Drive API Quickstart", and click the Create button.
- Click OK to dismiss the resulting dialog.
- Click the (Download JSON) button to the right of the client ID. Move this file to your working directory and rename it client_secrets.json.


## Running the Sample

You should have checked out the code and you should have it in a local
directory. If not check out the code to a local directory.

1. Run the application

        $ bundle exec rackup

2. Authorize the application in the browser window that opens

3. Your information retrieved from Google+ will be displayed
