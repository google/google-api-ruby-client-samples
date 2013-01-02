# Google+ Ruby Sample

This is a simple Sinatra web application that calls the Google+ APIs in ruby. 

## Prerequisites

Please make sure that you're running Ruby 1.8.7+ and you've run
`bundle install` on the sample to install all prerequisites.

## Setup Authentication

This API uses OAuth 2. You can learn more about
[Google APIs and OAuth 2](https://developers.google.com/accounts/docs/OAuth2).

Or, if you'd like to dive right in, follow these steps.
 - Visit the [API Console](https://code.google.com/apis/console/) to register
   your application.
 - From the "Project Home" screen, activate access to "Google+ API".
 - Click on "API Access" in the left column
 - Click the button labeled "Create an OAuth 2.0 client ID"
 - Give your application a name and click "Next"
 - Select "Web application" as the "Application type"
 - Enter "localhost:9292" as the site location
 - Click "Create client ID"
 - Edit your client settings
 - Change "Authorized Redirect URIs" from the default to
   "http://localhost:9292/auth/google/callback".
   Note that in production you'll want to use SSL.

Edit the `client_secrets.json` file and enter the client ID & secret that you
retrieved from the API Console:

## Running the Sample

You should have checked out the code and you should have it in a local
directory. If not check out the code to a local directory.

1. Run the application

        $ bundle exec rackup

2. Authorize the application in the browser window that opens

3. Your information retrieved from Google+ will be displayed
