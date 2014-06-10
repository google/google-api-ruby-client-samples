# Google Analytics API & Service Accounts Ruby Sample

This is a command line example of calling the Google Analytics API & service accounts. 

## Prerequisites

Please make sure that you're running Ruby 1.8.7+ and you've run
`bundle install` on the sample to install all prerequisites.

## Setup Authentication

This API uses OAuth 2.0 with service accounts. Learn more about Google APIs and OAuth 2.0 here:
https://developers.google.com/accounts/docs/OAuth2

Or, if you'd like to dive right in, follow these steps.
 - Visit https://code.google.com/apis/console/ to register your application.
 - From the "Project Home" screen, activate access to "Google+ API".
 - Click on "API Access" in the left column
 - Click the button labeled "Create an OAuth 2.0 client ID"
 - Give your application a name and click "Next"
 - Select "Service Account" as the "Application type"
 - Select "other" under "Installed application type"
 - Click "Create client ID"
 - Click 'Download private key' to save the generate private key file

Also:
 - In analytics, invite the service account email as a user to the project
 - Gather your [Profile Id][pi]

Edit analytics.rb with your apps' ID & credentials along with your analytics profile ID:

## Running the Sample

I'm assuming you've checked out the code and are reading this from a local
directory. If not check out the code to a local directory.

1. Run the application

        $ bundle exec ruby analytics.rb

[pi]: https://developers.google.com/analytics/devguides/reporting/core/v3/#started
