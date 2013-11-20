# DFA Reporting Ruby Samples
 
This is a collection of samples written in Ruby which provide a starting place
for your experimentation into the DFA Reporting API.

## Prerequisites

Please make sure that you're running Ruby 1.8.7+ and you've run
`bundle install` on the example directory to install all prerequisites.

## Setup Authentication

This API uses OAuth 2.0. Learn more about Google APIs and OAuth 2.0 here:
https://developers.google.com/accounts/docs/OAuth2

Or, if you'd like to dive right in, follow these steps.
 - Visit https://code.google.com/apis/console/ to register your application.
 - From the "Project Home" screen, activate access to "DFA Reporting API".
 - Click on "API Access" in the left column
 - Click the button labeled "Create an OAuth2 client ID"
 - Give your application a name and click "Next"
 - Select "Installed Application" as the "Application type"
 - Under "Installed application type" select "Other"
 - Click "Create client ID"
 - Click "Download JSON" and save the file as `client_secrets.json` in your
   home directory

## Running the Examples

I'm assuming you've checked out the code and are reading this from a local
directory. If not check out the code to a local directory.

1. Start up a sample, e.g.

        $ ruby create_report.rb <profile_id>

2. Complete the authorization steps on your browser

3. Examine your shell output, be inspired and start hacking an amazing new app!
