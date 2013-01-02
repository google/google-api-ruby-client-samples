## Prerequisites

Please make sure that you're running Ruby 1.8.7+ and you've run
`bundle install` on the sample to install all prerequisites.

# APIs Console Project Setup

If you have not yet, you must set your APIs Console project to enable Prediction
API and Google Storage. Go to APIs Console https://code.google.com/apis/console/
and select the project you want to use. Next, go to Services, and enable both
Prediction API and Google Storage. You may also need to enable Billing (Billing)
in the left menu.

# Data Setup

Before you can run the prediction sample prediction.rb, you must load some csv
formatted data into Google Storage. 

1 - You must first create the bucket you want to use. This can be done 
with the gsutil function or via the web UI (Storage Access) in the Google 
APIs Console. i.e. 

    $ gsutil mb gs://BUCKET

OR

Go to APIs Console -> Storage Access (on left) and the Google Storage Manager,
and create your bucket there.

2 - We now load the data you want to use to Google Storage. We have supplied a
basic language identification dataset in the sample for testing.

    $ chmod 744 setup.sh
    $ ./setup.sh BUCKET/OBJECT
Note you need gsutil in your path for this to work.

If you have your own dataset, you can do this manually as well.

    $ gsutil cp your_dataset.csv gs://BUCKET/your_dataset.csv


In the script, you must then modify the datafile string. This must correspond with the
bucket/object of your dataset (if you are using your own dataset). We have
provided a setup.sh which will upload some basic sample data. The section is
near the bottom of the script, under 'FILL IN DATAFILE'

## Setup Authentication

We need to allow the application to use your API access. Go to APIs Console
https://code.google.com/apis/console, and select the project you want, go to API
Access, and create an OAuth2 client if you have not yet already. Select "Service Account"
as the application type and download the generated private key file.

Edit predicton.rb and fill in your service account email and key file information
from the API Access page.


Usage
-----
At this, point, you should have 
 - Enabled your APIs Console account
 - Created a storage bucket, if required
 - Uploaded some data to Google Storage
 - Modified the script to point the 'datafile' variable to the BUCKET/OBJECT name
 - Modified the script to put your credentials in
 
We can now run the service! 

    $ bundle exec ruby prediction.rb

This should start a service on `http://localhost:4567`. When you hit the service,
your ruby logs should show the Prediction API calls, and print the prediction
output in the debug. 

This sample currently does not cover some newer features of Prediction API such
as streaming training, hosted models or class weights. If there are any
questions or suggestions to improve the script please email us at
prediction-api-discuss@googlegroups.com.
