How I learnt automating a data pipeline in the cloud
Through my journey towards data science, we covered a data engineering section in a bootcamp where we were asked by a fictitious e-scooter company whose name is Gans, to create an automated data pipeline in the cloud.

Gans needs data on the cities it operates in, data on the weather in those cities since e-scooter usage is greatly influenced by it, and flight arrivals since an important share of Gans e-scooters users are tourists.

This task was done in two phases.

First, the pipeline is built locally. So that correcting mistakes can be made where changing a database's design or troubleshooting is still simple.

In this phase, we executed scripts to gather data from the internet and save it in a database. The Jupyter notebooks on our computer was used to run the scripts, and our local MySQL instance was also used to generate the database.

The data that was needed, are related to the population, weather and flight arrivals.

In the first phase, we collected data using APIs, created a database and stored it locally.

Once everything works fine in the first phase, we move to the next one where we automated data collection and storing in the cloud.

Collecting data using APIs
There are lot of websites where you can find APIs. You can find an API for everything today since APIs serve as the primary point of integration for technologies. If it is not there, you can bet that someone is working on it.

One of the best website where you can find or discover APIs is RapidAPI. It is the world's largest API Marketplace where developers can search and test APIs, subscribe, and connect to them (What Is RapidAPI?, 2020).

Collecting weather data
E-scooter usage is greatly influenced by the weather. Rarely anyone wants to operate an e-scooter on cold or, particularly, rainy days. That is why it is of Gans interest to collect weather data.

For our project we will also use OpenWeatherMap which is an online service, owned by OpenWeather Ltd, that provides global weather data via API, including current weather data, forecasts, nowcasts and historical weather data for any geographical location (Wikipedia contributors, 2022).

To get weather data, we use the python requests library and make API calls using the following endpoint, which is a 5-day forecast with a 3-hour step as recommended in our data science bootcamp:



Where the link is the endpoint. City is the name of the city we are interested in its weather. Country is the ISO 3166-1 standard defining codes for the names of countries. And OWM_key is the API key that we received when we signed up for an account at OpenWeatherMap.

There are a few other API endpoints that are free to access even without an account which you can find in the API documentation section of the OpenWeatherMap website.

We then obtain weather data in a JSON format. And after exploring the response that we received, we selected the information that we find useful and made a data frame from them as follow:



We obtain a data frame that looks like this:



Collecting flights data
We are interested in gathering information regarding flights landing in our target cities because an important share of users of Gans e-scooters are tourists and many of them fly while carrying only a backpack.

The procedure of gathering data on the arrival flights in the cities of interested using an API is like the one we used for the weather. First, we find an API to request the information we are interested in, then explore the response and chose the most important variables for our project, and finally construct a final data frame that we will transfer later to the database that we will create in locally on MySQL.

For the arrivals data, we used this time, Aerodatabox api which you can found in the API Marketplace Rapid API. You would have first to create an account with Rapid API. Find the Aerodatabox api page and click on "Subscribe to test". It will direct you to a page where you can pick different subscriptions for the API. Since we need basic info for learning purposes, we pick the Basic, no-cost plan. Then, we could test the API by going to the Endpoints section.

Again, we use the request library to make an API call as follow:



We need for this call an IATA airport code, the local time we want flights info from and the local time we want this info to, with a maximum difference of 12 hours.

For a city that has more than one airport like Paris for example, we can get data on flight arrivals using the following code:



Data regarding cities and airports
We also collected data on cities using also an API and the procedure is again similar.

Regarding airports data, we were provided with a csv file with all the necessary information needed for our project. However, it is easy to find some file online with airports information.

Setting up a local database in MySQL Workbench
First, we start by creating a new database and then all the tables that we are going to need. For each table we specify the data type for each column.

Static tables:

A table with the names of all the cities that Gans operates in. This table will be manually filled, with a new row only appearing when the data set is expanded to include a new city. That is why we refer to it as static.

Airports table is the same. Only in the unlikely event that a new airport is constructed should it be altered.

Here is how the query to create the cities table looks like:



We end up with an empty table that would look like this when we fill it in with cities info:



For the airports table the query to create it looks as follow:



And we would end up with an empty table that would look as follow when we fill it in:



Weather Table

Connecting Python with MySQL
Now that we have all the information, we want in Pandas Dataframes or Python dictionaries, it is time to load them into the empty MySQL tables,

To do so, we need to connect Python with MySQL.

In our task we used SQLALchemy.

We had to specify the connection information to connect to the database we have created, after installing SQLALchemy library with pip install.





Then we use the pandas method DataFrame.to_sql() to transform the Dataframes into MySQL tables.



The argument if_exists = 'append' allows to insert new rows into the existing corresponding table that we have created on MySQL.

I ended up with this database schema that looks like this.



Setting up a cloud MySQL instance
Now it is the point where we move the data pipeline to the cloud. This will be done with the following steps:

Create an AWS account.

Setup an AWS RDS database.

Run Python data collecting scripts with AWS Lambda.

And finally, add a trigger with AWS EventBridge that makes it possible to schedule automatic script executions.

Signing up for an AWS account
A subsidiary of Amazon, Amazon Web Services, Inc. offers government agencies, businesses, and people metered pay-as-you-go cloud computing platforms and APIs. Through AWS server farms, these cloud computing web services offer software tools and distributed computer processing capacity.

Since every new AWS account comes with 12 months of "Free Tier" usage, signing up for account came with no expense and allowed us to apply what we have learnt so far and implement our automated data pipeline.

Setting up an Amazon RDS MySQL Instance
Setting up relational databases (like MySQL) in the cloud is really simple with the help of Amazon Relational Database Service (Amazon RDS).

You will find all the instructions how to create a MySQL DB instance and connect to it in the AWS documention.

Connecting to Amazon RDS MySQL Instance
You must be aware of the host address, or "endpoint," of your instance in order to connect to it. Click on your database by going to AWS Console > RDS > Databases. Copy the endpoint for the time being, which can be found under the "Connectivity & security" tab.

In MySQL workbench, we established a new connection by clicking on the tiny "+" icon on the MySQL home page.
Connection name: This is just a way for you to identify this connection to your AWS instance and can be anything.
Paste the instance endpoint that you copied from your AWS Console in the hostname field.
Port: 3306 will always be used.
The username will be "admin" (unless you changed it when creating the database).
Password: Enter the password you just chose when you created the AWS instance in RDS after clicking "Store in Keychain" (or "Store in Vault").
Moving the scripts to the cloud
Nowadays, serverless computing has become a new paradigm. You simply paste your script into the service, choose the programming language you will be using, and hit "run." Operating systems and hardware are not a concern! Although you cannot have it all, you will still need to take some action to ensure that the libraries your script depends on are accessible. This service is known as AWS Lambda in AWS.

Creating a Lambda function
We needed first to create something called a "Role" before we wrote our first Lambda function. Our Lambda function was able to connect to our RDS instance using this role. Cloud permissions are inconvenient yet necessary. Since we were merely learning and using sensitive data, we did not adhere to the best practice of "Minimum necessary permissions" in this case. The stages we took are as follows:

Creating a role:
These are the steps to create a role that enabled our Lambda function to connect to any service.

Sign in to your AWS console.
Type "IAM" into the top search bar and click on the result.
Select "Roles" from the menu on the left.
Then select "Create role."
Choose "AWS service" as the trusted entity type.
Choose "Lambda" as the use case
Click "Next"
Check the box of the policy "AdministratorAccess".
Select "Next."
Set "LambdaAdminAccess" as the name of the role.
Then select "Create role."
Create a Lambda function
These are the steps we took to create a lambda function:

Log in into AWS interface is step one.
Go to Services > Lambda in step 2.
Select "Create function."
Choose "Author from scratch."
Give the function a name that we could remember.
Go to Runtime and choose "Python 3.8".
Click "Change default execution role" under "Permissions," check "Use an existing role," and then choose the "LambdaAdminAccess" role that we created.
Then, click on "Create function."
Connecting the Lambda function to the RDS instance
Before creating the lambda function, we needed to create empty table corresponding to the cities that Gans operates in, that will take the arrival flights data and the weather data. But this time we used Connector/Python because it allowed to make queries from python to MySQL with the combination of For loops.

Here is the code:



Now going back to the lambda function dashboard, you can find the "Code Source" can be found by scrolling down. When you select lambda function.py, a window containing some code appears:



Here, we created the function that establishes a connection to the RDS instance we set up earlier and the code that requests the data for the arrivals and the weather corresponding for the cities Gans operates in as follow:



Testing the Lambda function
Before we deployed and test whether the function works, we needed to import the libraries our script depends on and do some troubleshooting.

Starting with importing the libraries, we needed to upload a layer with Python modules to our Lambda function. And these are the steps to add the dependencies:

We went back to the AWS console and to the Lambda function.
On the "Layer section" in the bottom of the page, we clicked on "Add a layer"
We clicked on AWS Layers.
Then we chose AWSDataWrangler-Python38 and select the latest version.
And finally clicked on "Add"
But unfortunately, SQLAlchemy was still missing, and we needed it for the code to do all of the tasks we needed it to. Fortunately, there is a publicly available work of one of the best developers out there who creates and maintains a list of lambda layers. And these are the steps followed to add the SQLAlchemy layer.

We went to Keith's layers GitHub repository.
We located the "List of ARNs" in the README.md by scrolling down and choosing the one that applies to the Python version we were using.
Clicked on the "html" link corresponding to where our lambda function was located, which can be found by looking at the top right on the AWS Console.
On the lengthy list of Python packages, we searched for SQLAlchemy and copy the ARN code.
The we went back to the lambda function in the AWS Console and added another Layer but this time we needed to click on "Specify an ARN" instead and paste the ARN code we copied from Keith's Layers repository.
Next, we need to do some troubleshooting, which is increase the timeout by going to "Configuration in the lambda function page, click on "Edit" and increase the timeout from 3 seconds to somewhere between 30 seconds and 5 minutes.

Then, our lambda function was ready to run without any errors and the test result should look like the screenshot below:



Automating the data pipeline with AWS EventBridge
Triggering the execution of scripts in the lambda function can be done using AWS EventBridge. The rules are simply defined for the execution of the scripts using using Cron expressions.

To create a trigger, we create first a rule and we chose the rule type "Schedule", a rule that runs on a schedule, we chose the rate at which the lambda function is executed, selected a target, that is, lambda function, then chose the lambda function we created click on "Next". We were able to see something like this in the lambda function page.



And Finally we come to the end of automating the data pipeline in the cloud.

References
What is RapidAPI? (2020, April 1). BrightTALK. https://www.brighttalk.com/webcast/17994/396215

Wikipedia contributors. (2022, June 22). OpenWeatherMap. Wikipedia. https://en.wikipedia.org/wiki/OpenWeatherMap
