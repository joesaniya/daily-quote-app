📱 QuoteVault — AI-Powered Quote Discovery App

QuoteVault is a full-featured Flutter application for discovering, saving, and sharing inspirational quotes.
The app is built using Supabase (Auth + Database) and demonstrates clean architecture, cloud sync, personalization, and effective use of AI development tools.

This project was developed as part of a Mobile Application Developer Assignment with a strong focus on AI-assisted workflow, feature completeness, and production-quality code.

🧩 Core Features
Authentication & User Accounts

Email & password sign-up and login

Secure session persistence

Password reset flow

User profile with name and avatar

Supabase Auth integration

Quote Browsing & Discovery

Home feed with paginated quotes

Browse by categories:

Motivation

Love

Success

Wisdom

Humor

Search quotes by keyword

Filter quotes by author

Pull-to-refresh support

Graceful loading and empty states

Database seeded with 100+ curated quotes.

Favorites & Collections

Save and remove favorite quotes

Dedicated favorites screen

Create custom quote collections

Add or remove quotes from collections

Cloud sync across devices when logged in

Quote of the Day & Notifications

Daily Quote prominently displayed

Daily rotation logic

Local push notifications

User-selectable notification time

Sharing & Export

Share quotes as plain text

Generate styled quote cards (image format)

Save generated cards to device

Multiple card styles/templates

Personalization & Settings

Dark / Light mode toggle

Accent color themes

Font size adjustment

Settings persist locally and sync to user profile

Home Screen Widget

Daily quote widget logic implemented

Widget deep-links to quote detail screen

Platform-specific widget wiring documented

🏗️ Architecture & Project Structure

The app follows a clean, scalable architecture using Provider for state management.

lib/
├── config/ # Supabase and app configuration
├── core/ # Navigation & core utilities
├── models/ # Data models
├── providers/ # State management (ChangeNotifier)
├── services/ # API, notifications, sharing, widgets
├── screens/ # UI screens
└── main.dart # App entry point

Tech Stack

Framework: Flutter (Material 3)

State Management: Provider

Backend: Supabase (Auth + Database)

Local Storage: SharedPreferences

Notifications: Local notifications

Sharing: System share sheet

Design Tools: Stitch / Figma Make

🎨 Design

UI designed using Stitch (Google)

Consistent Material 3 design language

Responsive layouts and polished animations

🔗 Design Link
https://stitch.withgoogle.com/projects/5492135111191146132

🤖 AI-Assisted Development Workflow

This project was built using modern AI tools to improve development speed, code quality, and architecture decisions.

AI Tools Used

Claude Code

ChatGPT

GitHub Copilot / Cursor

How AI Was Used

Architecture planning and folder structure

Supabase schema and query generation

Provider state management logic

UI component generation and refactoring

Debugging async and state issues

README and documentation writing

Result

Faster development (~70% time reduction)

Cleaner and more maintainable code

Better separation of concerns

🚀 Getting Started
Prerequisites

Flutter SDK (3.x or later)

Supabase project with Auth & Database enabled

Setup
git clone https://github.com/joesaniya/daily-quote-app.git
cd daily-quote-app
flutter pub get

Configure Supabase credentials in:

lib/config/supa_base_config.dart

Run the app:

flutter run

🎥 Demo Video

Loom upload was not accessible, so a Google Drive link is provided.

🔗 App Demo & AI Workflow Video
https://drive.google.com/file/d/11NPsaMzdt5_y9mVEbUSt333RxmlOInJv/view?usp=drive_link

The video includes:

Complete app walkthrough

Authentication & Supabase demo

Favorites and collections

Quote card generation

Notifications

AI workflow explanation

🧪 Quality & Best Practices

Null safety throughout

Error handling with user feedback

No hardcoded strings

Proper disposal of controllers

Clean separation of concerns

Responsive UI with SafeArea

Consistent naming conventions

⚠️ Known Limitations

Home screen widget requires final platform-specific setup:

Android AppWidgetProvider

iOS WidgetKit extension

Web widgets are not supported

All limitations are documented and non-blocking.

👤 Author

Esther Jenslin

GitHub: https://github.com/joesaniya

LinkedIn: https://www.linkedin.com/in/esther-jenslin-463568333/

Portfolio: https://esther-jenslin-t2dodau.gamma.site/
