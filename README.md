# Esports-app
## Web based platform that allows universities to easily display and manage  information about their teams and/or related esports events for both players and fans , ultimately making it easier to stay connected with a university's esports culture 
#


# Setup Instructions for Development:
## Step 1: Ensure Pyhton and MySQL is installed; Then Clone the repo. Referred IDE: VS Code
## Ensure Python Extenstion by microsoft is installed

## Step 2: Create And Actiavate Python Environment 
### Open Repo folder in VS Code (or other prefeered IDE)
### Method 1: (Use VS Code Pyhton Extension to create virtual environment):
### with folder open in VS Code, hit Ctrl+shift+p
### Search for "Python: Create Environment"

### Method 2:
### Run command in vs code terminal:
### py -m venv .venv 
### .\.venv\Scripts\Activate.ps1

## Step 3: Install Dependencies
### Open Repo folder in VS Code (or other prefeered IDE) and run the following command in terminal:
### python -m pip install -r requirements.txt

## Step 4: Setup MySQL Server
### Start a local MySQL Server through MAMP (or another MySQL installation). Execute the 'EsportsManagementDB.sql' in MySQL Workbench to create database and its test sample entries.

## Step 5: Configure Local Credientials in .env
### Run Command to Copy example enviornament variables: ' Copy-Item .env.example .env '
### OR create your own .env file directly under root file (same level as app.py) following this example format:

### DB_HOST=127.0.0.1
### DB_PORT=3306
### DB_NAME=EsportsManagementDB
### DB_USER=root
### DB_PASSWORD=root

## Step 6: Start Flask App in Terminal
### In VS Code Terminal run command: ' python -m flask --app app run --debug '
### to start the app.


## Step 7: Open The Website
### Once flask app is running, vs code terminal should print something like this:
### * Serving Flask app 'app'
### * Debug mode: on
### WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
### * Running on http://127.0.0.1:5000
### Ctrl + left click on the link: [http:](http://127.0.0.1:5000) to open the webpage locally or copy the url into your browser of choice.