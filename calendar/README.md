# Calendar Ruby Sample

This is a simple starter project written in Ruby which provides a minimal
example of Google Calendar integration within a Sinatra web application.

Once you've run the starter project and played with the features it provides,
this starter project provides a great place to start your experimentation into
the API.

## Prerequisites

Please make sure that you're running Ruby 1.8.7+ and you've run
`bundle install` on the sample to install all prerequisites.

## Setup Authentication

This API uses OAuth 2.0. Learn more about Google APIs and OAuth 2.0 here:
https://developers.google.com/accounts/docs/OAuth2

Or, if you'd like to dive right in, follow these steps.

**Old Google Developers Console**

 - Visit https://code.google.com/apis/console/ to register your application.
 - From the "Project Home" screen, activate access to "Calendar API".
 - Click on "API Access" in the left column
 - Click the button labeled "Create an OAuth2 client ID"
 - Give your application a name and click "Next"
 - Select "Web Application" as the "Application type"
 - Under "Your Site or Hostname" select "http://" as the protocol and enter
   "localhost" for the domain name
 - click "Create client ID"


**New Google Developers Console**

 - Visit https://code.google.com/apis/console/ to register your application.
 - Click "APIs" within the "API's & auth" section in the left column
 - Locate the "Calendar API" and activate the access to it.
 - Click "Registered apps" then click "REGISTER APP"
 - Give your application a name and Select "Web application" for the "Platform" then click "Register"
 - To setup your application's authorization credentials, click on "OAuth 2.0 Client ID"
 - Change the "Redirect URI" to  "http://localhost:4567/oauth2callback" and "Web Origin" to "http://localhost:4567"


Download the JSON file with the OAuth2 credentials and either rename it to "calendar.rb-oauth2.json" or 
rename it to client_secrets.json, with this the api-client library picks the credentials without further configuration.

## Running the Sample

I'm assuming you've checked out the code and are reading this from a local
directory. If not check out the code to a local directory.

1. Start up the embedded Sinatra web server

        $ bundle exec ruby calendar.rb

2. Open your web browser and see your activities! Go to `http://localhost:4567/`

3. Be inspired and start hacking an amazing new web app!
