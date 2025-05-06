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

### Backend Testing
To run backend tests:
1. From the backend folder enter `npm install` to download all relevant packages
2. Still in the backend folder enter `npm run...` and then the test you want (i.e. userTest or appTest)
3. To run all tests enter `npm run tests` into the commandline

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
- Ethan Yoon - Database utils and config, test scripting, README