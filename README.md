# YangonTV Subtitle Production Management System

A premium production-ready mobile-first Flutter application for managing subtitle production workflows.

## Features

- **Role-Based Access Control**: Admin, QC, and Editor roles.
- **Cinematic UI**: Dark mode, glassmorphism, and smooth animations.
- **Realtime Database**: Powered by Supabase.
- **Salary System**: Automated calculation of salary, deductions, and bonuses.
- **Attendance Tracking**: Point-based attendance system.
- **Analytics**: Comprehensive dashboards for all roles.

## Tech Stack

- **Frontend**: Flutter (Riverpod, GoRouter, FlChart)
- **Backend**: Supabase (Auth, Database, Storage)
- **Local Cache**: Hive

## Setup Instructions

1. **Supabase Setup**:
   - Create a new Supabase project.
   - Run the SQL script in `supabase/schema.sql` in the SQL Editor.
   - Copy your Project URL and Anon Key.

2. **Flutter Setup**:
   - Update `lib/main.dart` with your Supabase credentials.
   - Run `flutter pub get`.
   - Run `flutter run`.

3. **Build APK**:
   - Run `flutter build apk --release`.

## Project Structure

```
lib/
├── core/         # Router and app constants
├── models/       # Data models
├── services/     # Supabase and external services
├── providers/    # Riverpod state management
├── screens/      # UI Screens (Login, Dashboards)
├── widgets/      # Reusable UI components
├── themes/       # App styling
└── main.dart     # Entry point
```
