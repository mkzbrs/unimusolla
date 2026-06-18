# UniMusolla

## Project Overview
UniMusolla is a full-stack mobile application developed as a final project for the Application Development course. The system addresses a specific campus logistical problem by allowing university students to locate, report, and monitor the condition of prayer rooms (musollas) hidden within the academic lecture blocks (DKG). 

The project follows a three-tier architecture utilizing a mobile frontend, a server-side API, and a relational database to perform complete CRUD (Create, Read, Update, Delete) operations.

## Application Stack
* Frontend: Flutter (Native Material Design 3)
* Backend: PHP (RESTful API architecture)
* Database: SQLite

## System Features and CRUD Implementation
The application fulfills standard data operations mapped to real-world user actions:
* Create: Students can report a newly discovered or unlisted musolla by submitting its block, specific location, and current condition.
* Read: The application retrieves and displays a dynamic, up-to-date list of all reported campus musollas.
* Update: Users can modify the status of a specific musolla (for example, changing the status from "Needs Cleaning" to "Clean & Available").
* Delete: Users can remove an outdated, duplicate, or permanently closed musolla record from the database.

## Application Interface Structure
The frontend consists of four primary functional screens:
1. Authentication Screen: Handles user registration and secure login via matrics number.
2. Dashboard Screen: The main hub featuring a search input and a scrollable list of musolla cards populated dynamically via HTTP requests.
3. Report Form Screen: A structured data entry form with input validation to submit new locations.
4. Detail and Action Screen: Displays specific musolla information and houses the respective triggers for the update and delete API operations.

## Database Design
The system uses an SQLite database with two related tables to ensure data integrity.
* Users Table: Stores authentication credentials (id, matric_num, password).
* Musollas Table: Stores location data and statuses (id, user_id, dkg_block, location_desc, status). The user_id acts as a foreign key. Sample testing data is pre-populated within the database file.

## API Endpoints
The PHP backend processes standard HTTP POST and GET requests and returns formatted JSON responses. 
* /api/register.php
* /api/login.php
* /api/add_musolla.php
* /api/get_musollas.php
* /api/update_status.php
* /api/delete_musolla.php

## Setup and Installation Instructions

### Backend and Database Configuration
1. Move the `api` folder into your local server environment directory (for example, `htdocs` for XAMPP or MAMP).
2. Ensure the PHP SQLite extension is enabled in your `php.ini` configuration.
3. The `unimusolla.db` database file is included in the project root and is pre-configured to connect via the PHP connection script.

### Frontend Configuration
1. Open the Flutter project directory in your IDE.
2. Run `flutter pub get` in the terminal to install dependencies (specifically the `http` package).
3. Navigate to the API service file within the `lib` folder.
4. Update the base URL variable to match your local machine's IPv4 address (for example, `http://192.168.x.x/api/`). Do not use `localhost` if testing on a physical mobile device or external emulator.
5. Run the application using `flutter run`.
