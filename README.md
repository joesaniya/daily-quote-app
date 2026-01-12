# Daily Quote App 📱✨

A beautiful, modern Flutter application that delivers daily inspiration through curated quotes. Built with Material Design 3, featuring smooth animations, local favorites management, and seamless sharing capabilities.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## ✨ Features

- **Daily Inspiration**: Fetch random motivational quotes from ZenQuotes API
- **Favorites Management**: Save and organize your favorite quotes locally
- **Share Quotes**: Share inspiring quotes with friends via social media
- **Beautiful UI**: Modern Material Design 3 with custom theming
- **Smooth Animations**: Polished fade and scale animations for better UX
- **Dark Mode Support**: Automatic theme switching based on system preferences
- **Offline Support**: Fallback quotes when network is unavailable

## 📸 Screenshots

> _Add your app screenshots here_

## 🏗️ Architecture

The app follows a clean, layered architecture pattern:

```
lib/
├── models/              # Data models
│   └── quote.dart
├── services/            # Business logic & API calls
│   ├── quote_service.dart
│   └── favorites_manager.dart
├── providers/           # State management (Provider pattern)
│   ├── quote_provider.dart
│   └── favorites_provider.dart
├── screens/             # UI screens
│   ├── home_page.dart
│   └── favorites_page.dart
└── main.dart           # App entry point
```

### Tech Stack

- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **HTTP Client**: http package
- **Sharing**: share_plus
- **Design**: Material 3 with custom theming

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- iOS Simulator / Android Emulator or physical device

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/joesaniya/daily-quote-app.git
cd daily-quote-app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
# On connected device/emulator
flutter run

# For specific platform
flutter run -d chrome        # Web
flutter run -d macos         # macOS
flutter run -d android       # Android
flutter run -d ios           # iOS
```

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.1
  http: ^1.1.0
  shared_preferences: ^2.2.2
  share_plus: ^7.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## 🎨 Design Process

### Tools Used
- **Figma/Stitch**: UI/UX design and prototyping
- **Material Design 3**: Design system foundation
- **Color Palette**: Custom purple-based theme (#6B4EFF)

### Design Decisions
- **Typography**: Poppins font family for modern, clean readability
- **Color Scheme**: Purple primary color with automatic dark/light theme support
- **Spacing**: Consistent 8px grid system
- **Cards**: Elevated cards with subtle shadows for depth
- **Animations**: Subtle fade and scale effects for premium feel

stitch design: https://stitch.withgoogle.com/projects/5492135111191146132

## 🤖 AI-Assisted Development

This project was built leveraging modern AI coding tools to accelerate development and maintain code quality.

### AI Tools Used

1. **Claude Code** (Primary)
   - Architecture planning and code generation
   - Complex logic implementation
   - Refactoring and optimization

2. **GitHub Copilot / Cursor**
   - In-editor code completions
   - Quick fixes and suggestions
   - Boilerplate generation

3. **ChatGPT / Claude**
   - Problem-solving and debugging
   - Documentation writing
   - Code review and improvements

### Development Workflow

#### Phase 1: Planning & Design
```
AI Prompt: "Design a Flutter app architecture for a daily quotes app 
with favorites, sharing, and offline support. Use Provider for state 
management and suggest the best project structure."
```

#### Phase 2: Model & Service Layer
```
AI Prompt: "Create a Quote model class for Flutter that handles JSON 
from ZenQuotes API. The API returns {q: 'text', a: 'author'}. Include 
null safety, equality operators, and serialization methods."
```

#### Phase 3: State Management
```
AI Prompt: "Implement a QuoteProvider using ChangeNotifier that fetches 
quotes from an API service, handles loading states, errors, and includes 
a time-based greeting feature."
```

#### Phase 4: UI Implementation
```
AI Prompt: "Create a modern Material 3 home screen for a quotes app with:
- Gradient background
- Animated quote card with fade-in effect
- Action buttons for favorite, share, and refresh
- Bottom navigation bar"
```

#### Phase 5: Local Persistence
```
AI Prompt: "Implement a FavoritesManager service using SharedPreferences 
to store Quote objects. Include methods for add, remove, toggle, and 
retrieve all favorites with proper error handling."
```

### Effective Prompting Strategies

#### ✅ Good Prompts
- **Specific**: "Add a dismissible gesture to remove favorites with an undo snackbar"
- **Context-rich**: "The API sometimes returns null. Update the Quote.fromJson factory to handle missing fields with fallbacks"
- **Incremental**: "First create the basic UI, then add animations in the next step"

#### ❌ Avoided Prompts
- Too vague: "Make it better"
- Too broad: "Build the entire app"
- Without context: "Fix the error" (without sharing the error)

### AI-Assisted Problem Solving

**Challenge 1: Animation Synchronization**
```
Problem: Multiple animations conflicting on favorite toggle
AI Solution: Suggested using separate AnimationControllers with 
proper disposal and sequential animation chaining
```

**Challenge 2: Async State Management**
```
Problem: SharedPreferences causing race conditions
AI Solution: Recommended loading favorites in initState and 
using FutureBuilder pattern for initial load
```

**Challenge 3: API Error Handling**
```
Problem: App crashes on network failure
AI Solution: Implemented try-catch with fallback quotes and 
user-friendly error messages
```

### Time Savings

- **Manual Coding Estimate**: 12-15 hours
- **AI-Assisted Actual Time**: 4-5 hours
- **Time Saved**: ~70% faster development
- **Code Quality**: Improved with AI-suggested best practices

## 📱 App Demo

> **[Link to Loom Video Demo](#)** _(4-5 minutes)_

Demo includes:
1. ✅ Full app walkthrough on simulator
2. ✅ Design process in Figma/Stitch 
3. ✅ AI workflow examples with real prompts
4. ✅ Iteration and debugging showcase

## 🧪 Testing

Run tests with:
```bash
flutter test
```

Generate coverage report:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🚢 Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 📝 Code Quality

### Linting
The project uses `flutter_lints` for code analysis:
```bash
flutter analyze
```

### Formatting
```bash
flutter format .
```

### Best Practices Implemented
- ✅ Const constructors for performance
- ✅ Proper disposal of controllers
- ✅ Null safety throughout
- ✅ Error handling with user feedback
- ✅ Separation of concerns (models, services, providers, UI)
- ✅ Responsive design with SafeArea
- ✅ Accessibility considerations

## 🔮 Future Enhancements

- [ ] Search functionality in favorites
- [ ] Categories/tags for quotes
- [ ] Custom quote creation
- [ ] Cloud sync across devices
- [ ] Widget for home screen
- [ ] Notification reminders
- [ ] Multiple language support
- [ ] Quote of the day history

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



## 👤 Author

**Your Name**
- GitHub: https://github.com/joesaniya
- LinkedIn: https://www.linkedin.com/in/esther-jenslin-463568333/
- Portfolio: https://esther-jenslin-t2dodau.gamma.site/

## 🙏 Acknowledgments

- [ZenQuotes API](https://zenquotes.io/) for providing free quotes
- Flutter team for the amazing framework
- AI tools (Claude, Copilot) for accelerating development
- Material Design team for design guidelines

## 📞 Support

For support, email estherjenslin1999@example.com or create an issue in the repository.

---
