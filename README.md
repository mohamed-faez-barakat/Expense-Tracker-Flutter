# Expense Tracker

A Flutter expense-tracking application with Supabase integration.

## Current project structure

The Flutter source is under `lib/`. The codebase includes screens and flows for:

- Welcome, sign-up, login, email verification, and password reset
- Home dashboard and transaction management
- Adding transactions
- Budgets, charts, and currency-related screens
- Light and dark theme handling

The app uses Supabase authentication and queries transaction data from a Supabase table.

## Tech stack

- Flutter / Dart
- Supabase Flutter
- fl_chart
- HTTP

## Requirements

- Flutter SDK compatible with the Dart SDK constraint in `pubspec.yaml`
- Android Studio or Visual Studio Code with Flutter and Dart extensions
- A Supabase project configured for the app's authentication and database schema

## Run locally

1. Clone the repository.
2. Open a terminal in the repository root.
3. Install packages:

   ```bash
   flutter pub get
   ```

4. Configure the Supabase project URL and publishable key in `lib/main.dart` for your own environment. Do not put a Supabase service-role key or other server secret in a client application.
5. Confirm that the Supabase database has the table and columns expected by the app.
6. Run the application:

   ```bash
   flutter run
   ```

## Security notes

The Supabase publishable key is intended for client-side use, but database access must be protected with correctly configured Row Level Security (RLS) policies. Never expose a service-role key. Review the Supabase policies before using real user data.

## Repository notes

Generated Flutter build output and local tool caches should not be committed. The existing `.gitignore` excludes the main generated directories.
