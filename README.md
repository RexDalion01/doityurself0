# doityurself0

# Taskly
//* It is a simple and minimalistic app made from flutter and dart, it helps users to organize their daily activities, manage their tasks, and monitor their productivity with a clean and smooth interface*//

# Features
//* 
View Tasks - lets the user display tasks in an organized list
Add Tasks -  Lets the user add tasks and enter its title and cateogry
Task Categories - Lets the user organize their tasks into Personal, School, Chore, Shopping, etc.. categories.
Complete Tasks - Mark tasks as completed and undo their completion
Edit Tasks - Modify the details of the task
Delete Tasks - Remove tasks that are no longer needed
Progression Tracking - Monitor the completion of a task through a dynamic progress indicatior
Task Counter - Monitors the total amount of pending tasks
Empty Indication - Lets users know that there are no pending task as of the moment
*//

# Built with
//*
- Flutter - used for the UI framework
- Dart - Programming Language
- SQLite - Planned local database
- sqflite - Planned SQLite integration
- Material Design - User interface components
*//

## Getting Ready

# Prerequisites

- Flutter SDK
- Dart SDK
- code editor(i.e. VS Code)
- Device Emulator(i.e. Android Studio)

# Installation
1. Clone Repository
 git clone https://github.com/RexDalion01/doityurself0.git
2. Navigate to the directory of the project
cd doityurself0
3. Install dependencies
flutter pub get
4. Run App
flutter run

# Project Structure
├── models/
│   └── task_model.dart
├── screens/
│   └── home_screen.dart
├── services/
│   └── database_service.dart
├── widgets/
├── theme/
└── main.dart

To note: the model and database service file are part of the planned project structure

# Data Storage
//*
Taskly is planned to use SQLite for local data storage through the sqflite package.

The database will be responsible for:

- Save tasks locally on the device 
- Retrieving those saved tasks
- Updating existing task information
- Removing tasks from the database
- Preserving task data after the application is closed

# Future Improvements 
- Complete SQLite integration
- Add task priority tier
- Implement Task due dates
- Add task descriptions
- Implement Task search and filter
- Add task statistics and productivity summaries
- Improve the interface with animations and additional visual feedback

# Purpose
Taskly is a personal Flutter learning and portfolio project developed to practice the authors dart programming skills, this includes Flutter widgets, object-oriented programming, State management, CRUD operations, and local database integration.

Taskly - Is to organize your tasks. track your progress, and stay positive.

# Updates
11/20
//Added model, database, 
//modified home screen dart to integrate database

11/21
//Added due dates - Made changes on task_model, database_service, and home_screen


