# Calendar Ruby Sample
This is a simple command line example of calling the Google+ APIs in ruby. 

## Prerequisites
Please make sure that all of these are installed before you try to run the
sample.

- Ruby 1.8.7+
- A few gems (run 'sudo gem install <gem name>' to install)
    - google-api-client
    - thin
    - launchy

## Setup Authentication

This API uses OAuth 2.0. Learn more about Google APIs and OAuth 2.0 here:
https://developers.google.com/accounts/docs/OAuth2

Or, if you'd like to dive right in, follow these steps.
 - Visit https://code.google.com/apis/console/ to register your application.
 - From the "Project Home" screen, activate access to "Google+ API".
 - Click on "API Access" in the left column
 - Click the button labeled "Create an OAuth 2.0 client ID"
 - Give your application a name and click "Next"
 - Select "Installed Application" as the "Application type"
 - Select "other" under "Installed application type"
 - click "Create client ID"

Edit the client_secrets.json file and enter the client ID & secretthat you 
retrieved from the API Console:

## Running the Sample

I'm assuming you've checked out the code and are reading this from a local
directory. If not check out the code to a local directory.

1. Run the application

        $ ruby plus.rb

2. Authorize the application in the browser window that opens

3. Your Google+ activity will be displayed on the command line
