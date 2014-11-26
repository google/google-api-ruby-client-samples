# Quickstart: Retrieve attachments from gmail

This examples shows how to retrieve automatically attachments from your
gmail. This was my original purpose, but it shows ho to use a few api requests.

## Enable the Drive API

First, you need to enable the Drive API for your app. You can do this in your
app's API project in the [Google APIs
Console](https://code.google.com/apis/console/).

1. Create an API project in the [Google APIs
   Console](https://code.google.com/apis/console/).
2. Select the **Services** tab in your API project, and enable the Gmail API.
3. Select the **API Access** tab in your API project, and click **Create an
   OAuth 2.0 client ID**.
4. In the **Branding Information** section, provide a name for your application
   (e.g. "Drive Quickstart Sample"), and click **Next**.  Providing a product
   logo is optional.
5. In the **Client ID Settings** section, do the following:
      1. Select **Installed application** for the **Application type**
         (or **Web application** for the JavaScript sample).
      2. Select **Other** for the **Installed application type**.
      3. Click **Create Client ID**.
6. In the **API Access** page, locate the section **Client ID for installed
   applications**, and click "Download JSON" and save the file as
   `client_secrets.json` in your home directory.

## Install the Google Client Library

To run the quickstart sample, you'll need to install the Google API client
library.

    bundle install

## Run the Sample

First of all, you need to have set up your application from the Google developers console.

You also need to have set up an account for your application.

I did this using this [API reference](https://developers.google.com/accounts/docs/OAuth2InstalledApp#handlingtheresponse)
and postman to send my request.

Once you do, you should be given an access and refresh token, just add those at the beginning of the code

You can finally run the sample with

    bundle exec ruby gmail.rb

## What does it do

This ruby script scans all labels in your account, for each of them, retrieves all unread messages that were received
less than 2 days ago, and downloads each of the attachment to a file.

After that, it marks mails as read, and sends automatic reply to the sender.

It contains examples to:
 - get the list of labels
 - get mails using filters
 - retrieve attachments
 - apply a label to an email
 - finally, send an email