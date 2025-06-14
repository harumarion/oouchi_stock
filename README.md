# oouchi_stock

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase configuration

This project uses Firebase. The configuration files `lib/firebase_options.dart` and `android/app/google-services.json` contain API keys and other secrets, so they are excluded from version control.

1. Copy the provided templates and add your own values:
   ```bash
   cp lib/firebase_options.example.dart lib/firebase_options.dart
   cp android/app/google-services.json.example android/app/google-services.json
   ```
2. Fill in the placeholders in each file with the values from your Firebase project or generate them using `flutterfire configure`.
3. You can keep these secrets outside of source control by using environment variables and packages such as [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv).
4. Create an `.env` file for local development:
   ```bash
   cp .env.example .env
   ```
   Define your Firebase API keys and other settings in this file. `flutter_dotenv` or
   `--dart-define-from-file=.env` can load the values at runtime.

The created `lib/firebase_options.dart`, `android/app/google-services.json` and `.env`
files are ignored via `.gitignore` and must be prepared locally before running the app.
