# CivicFix (DistrictDirect)

A mobile-first civic engagement platform built with Flutter that helps citizens report local issues and track progress, while district officials manage incidents and communicate updates.

## Overview

CivicFix connects two user roles in one app:

- Citizen experience: report incidents, view district feed, track issue status, and chat with district teams.
- Admin experience: district-level workflows for issue review, field progress updates, and communication.

The app uses Firebase for authentication and backend data, and supports multilingual UI with English, French, and Kinyarwanda.

## Key Features

- Role-based login flows for Citizens and Admins
- Incident reporting with media support
	- Photo capture/upload
	- Voice recording
- District feed with status tracking
- Real-time chat between citizens and district officials
- Location-aware reports and map integrations
- User preferences
	- Theme mode (light/dark)
	- Language selection
	- Notification settings

## Tech Stack

- Flutter + Dart
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Firebase Storage
- Provider (state management)
- Shared Preferences
- Geolocator + Flutter Map

## Project Structure

```
lib/
	constants/       # App colors, text styles, validation constants
	l10n/            # Localization files and generated translations
	providers/       # App settings and auth state management
	screens/         # UI screens (auth, citizen, admin, shared)
	services/        # Firebase/auth service layer
	utils/           # Validators and helpers
	main.dart        # App entry point
```

## Prerequisites

Before running the app, make sure you have:

- Flutter SDK installed
- Dart SDK (included with Flutter)
- Android Studio or VS Code with Flutter/Dart extensions
- A configured Firebase project
- A connected device or emulator

## Setup

1. Clone the repository

```bash
git clone https://github.com/KABASINGAarsene/civic-fix.git
cd civic-fix
```

2. Install dependencies

```bash
flutter pub get
```

3. Configure Firebase

- Ensure Firebase configuration files are present for your targets.
- This project already includes platform folders and Firebase integration points.
- Verify app identifiers and Firebase project mapping before running.

4. Run the app

```bash
flutter run
```

## Build Commands

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS (on macOS)
flutter build ios

# Web
flutter build web
```

## Screenshots

### Auth

- Citizen Login
![citizen login screen](image.png)
- Admin Login
![admin login screen](image-1.png)

### Citizen Flow

- Home / District Feed
![home screen](image-2.png)
- Create Report
![create report screen](image-3.png)
- My Reports
![my reports screen](image-4.png)
- Chats
![chats screen](image-5.png)
- Profile / Preferences
![profile screen](image-6.png)

### Admin Flow

- Dashboard
![admin home screen](image-7.png)
- Issue Management
![issues screen](image-8.png)
- District Field Map
![map screen](image-9.png)
- Chat Center
![chats screen](image-10.png)
- Profile
![profile screen](image-11.png)
