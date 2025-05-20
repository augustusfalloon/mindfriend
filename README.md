# MindFriend

A social app designed to help users regulate their screen time and be more mindful of their digital habits, particularly beneficial for individuals with ADHD.

## Project Overview

This repository contains both the iOS frontend and Node.js backend for the MindFriend application.

## Frontend (iOS App)

### Final Features
- User authentication 
- App usage tracking and restrictions
- Social accountability through friend connections
- Customizable high-risk time periods
- Real-time activity sharing with friends

### Technical Stack
- SwiftUI for modern UI development
- iOS 15.0+ support
- MVVM architecture

### Frontend Testing
1. Navigate to the `frontend/ios` directory
2. Open `MindFriend.xcodeproj` in Xcode
3. Hit the run button in Xcode, make sure iOS simulator is installed
4. To run tests, open project in Xcode and hit command u

## Acceptance Tests For TA

1. Enter Text into the log in screen
2. Check that you are brought into the main view after hitting Logging In.
3. Check that clicking different menu icons brings you to different screens.



## Project Structure

- `Views/`: Contains all SwiftUI views
  - `LoginView.swift`: User authentication screen
  - `MainTabView.swift`: Main app interface with tabs
- `Models/`: Data models
- `ViewModels/`: View models
- `Services/`: Network and business logic

## Backend
Currently in initial development phase with basic UI 
components implemented. Otherwise, Milestone 3A was 
followed closely.

### Getting Started
1. Navigate to the `backend` directory
2. Run `npm install` to download all relevant packages
3. Start the server with `npm start`

### Changed Backend Tests
The testing scripts in both the app tests and user tests documents have changed slightly. This is only to reflect updated function implementation with the classes (i.e. we have a method that creates a new instance as opposed to the test doing so manually). Additionally, the tests in user tests look different because we wanted to test them more manually than relying on HTTP messaging before. So, to be clear, they test exactly the same function, it is just done at a lower level and more directly. 

### Backend Testing
To run backend tests:
1. From the backend folder enter `npm install` to download all relevant packages
2. Still in the backend folder enter `node tests/user2.test.js `
Note: if you are receiving an error: "❌ Mongoose connection error: MongooseServerSelectionError: connect ECONNREFUSED ::1:27017, connect ECONNREFUSED 127.0.0.1:27017". There may be a couple things happening. First, you want to make sure that you are not trying to run our project from an SSH connection. Secondly, you may need to install MongoDB on your computer in order to connect to the database backend. If you are on a mac, use the following commands:
$brew install mongodb-community@7.0
$brew services start mongodb/brew/mongodb-community@7.0

### Implementation Status
- Connection with MongoDB database has been created
- New documents for new apps and users are functional
- Methods for each object can be found in their controllers and schemas
- Test scripts have been created
- Initial implementation of routes for frontend API is underway
- Full integration with the frontend is in progress

## Development Team

### Frontend
- Gus - Coded LoginView.swift, MainTabView.swift and MindFriendTests.swift
- Andrew - Coded ContentView.swift, MindFriendTests.swift
- Leena - Coded MainTabView.swift, MindFriendUITests.swift

### Backend
- Ethan Yoon - Database utils and config, test scripting, README, Integrated new app interface through user, updated app.test.js for full functionality with DB. 
- Joshua Enebo - functions in userController.js, appController.js, changes to the user and app classes, and wrote some tests in app.test.js and user.test.js
- Luke Hermann - wrote backend tests (app.test.js, user.test.js), and helped write functions in appController, as well as looked into integration between front and backend with routing
- Jake Zucker - wrote some backend tests for app.test.js, helped to work through initial phases of integration through use of XCode, contributed to design for appController.js 


### Milestone 4.B
## Backend
# 1
1. Backend implementation is fully completed with routes for frontend integration to follow before Milestone 6. 
2. Tests check not only for correct field implementation but that they are corectly saved in the database, this was not the case in previous iterations
3. Testing criteria and logging is more concise
4. appRoutes is depreciated. All methods for creating and saving apps is now run through user model and routes.
5. Created new user2.tests to test that functionality
# 2
1. Not yet implemented is front end integration

##Frontend
In this second development iteration, we are moving beyond the internal app logic and settings (which were largely completed in Iteration 1) to implement the core interaction mechanisms and social features that give MindFriend its value. These include:
Accessing Restricted Apps:
    Explore and implement ways to detect when a user attempts to open a restricted app during a high-risk time.
    Trigger a blocking overlay with a countdown timer and/or justification prompt.

Timer Implementation:
Implement a 60-second wait period before users can enter a restricted app.
Allow users to bypass the timer by submitting a justification.

Justification Entry + Sharing:

Store and timestamp user-submitted reasons for restricted app use.
Post those reasons to a shared feed visible to connected friends.

Friend Notifications:

Notify friends in real-time when someone they follow opens a restricted app and submits a reason.
Build a push notification system that links directly to the feed view.

Friend System Implementation:


Users can search for, add, and accept/reject friend requests.
    Friends will form the user’s accountability circle, with feed visibility limited to those connections.


What We Are Not Implementing in Iteration 2

Full iOS-level enforcement/blocking via Device Management (MDM):
 Due to iOS platform restrictions and the scope of this class project, we will not be implementing true app-blocking capabilities. Instead, we will simulate this via timely notifications, overlays, and user interactions.


Gamification, analytics dashboards, and AI-based habit prediction:
 These are stretch goals for future development but will not be tackled during this iteration due to complexity and prioritization of core use cases.




### Structure 
This is a general first idea of how we can structure our project.

mindfriend/
├── frontend/                      # iOS App (Swift)
│   ├── Models/
│   │   ├── User.swift
│   │   └── App.swift
│   ├── Views/
│   │   ├── User/
│   │   └── App/
│   ├── ViewModels/             # MVVM if we decide to use SwiftUI
│   ├── Networking/
│   │   └── APIService.swift
│   ├── Resources/              # Potentially Assets, LaunchScreens, etc.
│   ├── Utilities/
│   └── AppDelegate.swift
│
├── backend/                     # Node.js Backend
│   ├── src/
│   │   ├── controllers/ # Handle request logic (business rules, data transformation, validation).
│   │   │   ├── userController.js # Handles user-related logic: register/login, retrieve user profile info, update user preferences
│   │   │   └── appController.js # Log a justification from user, fetch usage log for specific app
│   │   ├── models/ # Define Mongoose schemas for simpler MongoDB collections?
│   │   │   ├── user.js 
│   │   │   └── app.js
│   │   ├── services/
│   │   │   └── databaseService.js    # potentially db functions to save new app log, get logs by user, save user preferences
│   │   └── index.js            # main entry point to handle the server-side stuff
│   ├── .env
|   ├── tests/
│   │   ├── app.js
│   │   ├── user.js
│   ├── package.json
│   └── README.md
│
├── docs/                       # Architecture, API contracts, etc.
│   └── api-spec.md
│
├── README.md
└── .gitignore
