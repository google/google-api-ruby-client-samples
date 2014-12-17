# Quickstart: Run a Drive App

Complete the steps described in the rest of this page, and in less than five
minutes you'll have a simple Drive app that uploads a file to Google Drive.

## Enable the Drive API

First, you need to enable the Drive API for your app. You can do this in your
app's API project in the [Google APIs
Console](https://code.google.com/apis/console/).

1. Create an API project in the [Google APIs
   Console](https://code.google.com/apis/console/).
2. Select the **Services** tab in your API project, and enable the Drive API.
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

## Set up the sample

Create a text file named `document.txt`, containing the text `Hello world!`.

## Run the Sample

After you have set up your Google API project, installed the Google API client
library, and set up the sample source code, the sample is ready to run.  The
command-line samples provide a link you'll need to visit in order to
authorize the sample.

    bundle exec ruby drive.rb

1. Browse to the provided URL in your web browser.
2. If you are not already logged into your Google account, you will be prompted
   to log in.  If you are logged into multiple Google accounts, you will be
   asked to select one account to use for the authorization.
3. The application automatically receives the authentication code and resumes
   operation.

When you finish these steps, `document.txt` is now stored in Google Drive.
The command-line samples print Information about the Google Drive file to the screen.
The file `document.txt` is accessible in Google Drive, and is titled "My
Document".

By editing the sample code to provide paths to new files and new titles,
you can run a few more simple upload tests. When you're ready, you
could try running some other Drive API methods such as
[files.list](http://developers.google.com/drive/v2/reference/files/list).

## Next Steps

If your goal is to let users create and open files directly from the Drive UI
using your app, see [Integrate with the Drive UI](https://developers.google.com/drive/enable-sdk).
Our end-to-end [Example Apps](https://developers.google.com/drive/examples/index) demonstrate a simple
Drive UI-integrated web app.

If your goal is to expand the quickstart sample into something for your own
installed application, consult the [API Reference](https://developers.google.com/drive/v2/reference). The
API Reference discusses all of the features of the Drive API, and gives
samples in each language on how to use a feature.

All requests to the Drive API must be authorized by an authenticated user.
To examine more authorization code and learn how to authorize requests,
see [Retrieve and Use Credentials](https://developers.google.com/drive/credentials).
