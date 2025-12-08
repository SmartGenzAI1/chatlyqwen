

**README.md**
```markdown
# 🚀 Chatly - Smart, Private & Anonymous Chat App

<div align="center">
  <img src="assets/images/logo/logo_full.png" width="300" alt="Chatly Logo">
  <h3>Intelligent messaging with privacy at its core</h3>
  <p>
    <a href="https://github.com/yourusername/chatly/releases">
      <img src="https://img.shields.io/github/v/release/yourusername/chatly?style=flat-square" alt="Version">
    </a>
    <a href="https://github.com/yourusername/chatly/actions">
      <img src="https://img.shields.io/github/actions/workflow/status/yourusername/chatly/build-apk.yml?branch=main&style=flat-square" alt="Build Status">
    </a>
    <a href="https://github.com/yourusername/chatly/issues">
      <img src="https://img.shields.io/github/issues/yourusername/chatly?style=flat-square" alt="Issues">
    </a>
    <a href="https://github.com/yourusername/chatly/stargazers">
      <img src="https://img.shields.io/github/stars/yourusername/chatly?style=flat-square" alt="Stars">
    </a>
  </p>
</div>

## 🌟 Overview

Chatly is a revolutionary text-only messaging application that combines **privacy**, **smart algorithms**, and **anonymous connections** to create a truly unique chat experience. Built with Flutter and Firebase, Chatly offers features like anonymous "Lucky Chat", smart notification timing, conversation health scores, and a freemium subscription model with advanced features for Plus and Pro users.

## ✨ Key Features

### 🔒 Privacy-First Design
- **7-day message auto-deletion** (configurable for premium users)
- **End-to-end encryption** for all standard chats
- **Anonymous user discovery** via `@username` instead of phone numbers
- **Optional contacts sync** with hashed data for privacy
- **Auto account deletion** after 40-70 days of inactivity

### 🤖 Smart Algorithms
- **Smart Notification Timing**: Reduces notification fatigue by 40-60%
- **Most Chatted Sorting**: Real-time contact ranking based on engagement
- **Conversation Health Score**: Pro-exclusive group health monitoring
- **Interest-Based Matching**: Connects anonymous users with similar interests

### 🎭 Anonymous "Lucky Chat"
- **Topic-tagged messages** (#advice, #fun, #question)
- **Tiered usage limits**:
  - **Free**: 3 messages/week (100 characters)
  - **Plus**: 10 messages/week (250 characters) - ₹199/year
  - **Pro**: Unlimited messages (500 characters) - ₹299/year
- **Connection requests** to transition from anonymous to regular chat

### 💎 Premium Tiers
| Feature | Free | Plus (₹199/year) | Pro (₹299/year) |
|---------|------|------------------|-----------------|
| Anonymous Messages | 3/week (100 chars) | 10/week (250 chars) | Unlimited (500 chars) |
| Group Creation | ❌ | 1 group | 2 groups |
| Themes | 3 | 15+ | Unlimited custom |
| Wallpapers | 3 gradients | 50+ HD | Unlimited animated |
| Message Retention | 7 days fixed | 2-7 days choice | 2-7 days + .txt backup |
| Ads | Banner ads | No ads | No ads + early access |
| Algorithms | Basic | Smart matching | Advanced + analytics |

## 🛠 Technical Architecture

### Frontend
- **Language**: Dart
- **Framework**: Flutter 3.19.0
- **State Management**: Provider + Riverpod
- **UI**: Custom animations with Lottie, Google Fonts, Shimmer effects

### Backend
- **Authentication**: Firebase Authentication (Email/Password, Phone OTP)
- **Database**: Cloud Firestore (NoSQL)
- **Functions**: Cloud Functions for server-side logic
- **Storage**: Firebase Storage (limited usage)
- **Notifications**: Firebase Cloud Messaging (FCM)

### APIs & Services
- **Unsplash API**: Free HD wallpapers
- **Perspective API**: Real-time toxicity detection
- **RevenueCat**: Subscription management
- **Google Fonts**: Typography

## 📦 Installation

### Prerequisites
- Flutter 3.19.0 or higher
- Dart 3.0.0 or higher
- Firebase account
- Android Studio or Xcode (for mobile builds)

### Setup Instructions

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/chatly.git
cd chatly
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Set up Firebase:**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add Android and iOS apps to your Firebase project
   - Download `google-services.json` and `GoogleService-Info.plist`
   - Place files in appropriate directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Configure environment variables:**
```bash
cp .env.example .env
# Edit .env with your actual API keys and configuration
```

5. **Run the app:**
```bash
# Development mode
flutter run

# Production build
flutter build apk --release
```

### Direct APK Download
For users who want to try the app without building:
1. Go to [Releases](https://github.com/yourusername/chatly/releases)
2. Download the latest `app-release.apk`
3. Install on your Android device (enable "Unknown sources" in settings)

## 🧪 Testing

### Run all tests:
```bash
flutter test
```

### Run tests with coverage:
```bash
flutter test --coverage
```

### Specific test files:
```bash
# Unit tests
flutter test test/features/chat/domain/use_cases/send_message_use_case_test.dart

# Widget tests
flutter test test/features/chat/presentation/widgets/chat_list_item_test.dart
```

## 🚀 Deployment

### GitHub Actions
This project uses GitHub Actions for automated builds:
- **On push to main**: Builds APK and creates a GitHub Release
- **On pull request**: Runs tests and static analysis
- **Manual trigger**: Can be run on-demand for hotfixes

### Distribution Channels
1. **Primary**: GitHub Releases (direct APK download)
2. **Secondary**: F-Droid (open-source app store)
3. **Future**: Google Play Store, App Store (after monetization validation)

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**:
```bash
git checkout -b feature/your-feature-name
```
3. **Commit your changes**:
```bash
git commit -m 'feat: add your feature description'
```
4. **Push to the branch**:
```bash
git push origin feature/your-feature-name
```
5. **Open a pull request**
6. **Follow the PR template** and include screenshots for UI changes

### Contribution Guidelines
- Write clear, meaningful commit messages
- Follow the existing code style and patterns
- Add tests for new features
- Update documentation when needed
- Ensure all tests pass before submitting PR

## 📄 Documentation

### Project Structure
```
lib/
├── core/           # Core utilities, constants, themes
├── data/           # Data models, repositories, datasources
├── services/       # Business logic services
├── features/       # Feature modules (auth, chat, anonymous, etc.)
├── providers/      # State management providers
├── router/         # Navigation and routing
└── main.dart       # App entry point

assets/
├── images/         # App icons, logos, illustrations
├── animations/     # Lottie animations
├── fonts/          # Custom fonts
└── wallpapers/     # Background images

test/               # Unit and widget tests
android/            # Android platform code
ios/                # iOS platform code
```

### Architecture
Chatly follows **Clean Architecture** principles with clear separation of concerns:
- **Presentation Layer**: UI components, screens, widgets
- **Domain Layer**: Business logic, use cases, entities
- **Data Layer**: Data sources, repositories, models
- **Core Layer**: Shared utilities, constants, errors

## 🔒 Security

### Data Protection
- All messages are encrypted in transit and at rest
- User data is anonymized for analytics
- Regular security audits and dependency updates
- Rate limiting and abuse prevention

### Compliance
- GDPR compliant data handling
- Privacy policy and terms of service
- Data deletion on request
- Age-appropriate content filtering (13+)

## 📊 Analytics & Monitoring

### Key Metrics Tracked
- Daily Active Users (DAU)
- Message delivery rate (target: 99.5%)
- Crash rate (target: <0.5%)
- User retention (target: 40% day 7, 20% day 30)
- Premium conversion rate (target: 5%)

### Tools Used
- Firebase Analytics
- Firebase Crashlytics
- RevenueCat for subscription analytics

## 🌍 Localization

### Supported Languages
- English (default)
- Hindi (priority)
- Spanish (planned)
- French (planned)

### Adding New Languages
1. Create translation files in `lib/l10n/`
2. Update `l10n.yaml` configuration
3. Run `flutter gen-l10n`
4. Test with different locales

## 💰 Monetization

### Revenue Model
- **Free tier**: Banner ads, limited features
- **Plus tier**: ₹199/year, removes ads, adds features
- **Pro tier**: ₹299/year, all features unlocked

### Revenue Targets
- **Break-even**: 1,000 active users
- **Profitability**: 5% conversion rate to premium
- **Scaling**: Expand to iOS and web platforms

## 🚨 Critical Notes

### Storage Optimization
- **Text-only focus**: No image sharing to control costs
- **Message compression**: Before sending to Firestore
- **Local caching**: 24-hour expiration for offline access
- **Batch operations**: Minimize Firestore reads/writes

### Cost Control
- **Free tiers**: Firebase free tier until ~50k users
- **WhatsApp OTP**: Instead of SMS for authentication
- **Unsplash**: Free wallpapers instead of paid assets
- **RevenueCat**: Free tier for subscriptions under $10k/month

### Moderation Challenges
- **Real-time filtering**: For anonymous chat content
- **Community reporting**: Essential for scaling moderation
- **Automated bans**: Based on user report algorithms
- **Manual review**: For permanent bans and appeals

## 📞 Support

### User Support
- **In-app FAQ**: Comprehensive help section
- **Email**: support@chatly.app
- **WhatsApp Business**: +91XXXXXXXXXX
- **Response time**: 24 hours to 7 days

### Developer Contact
- **GitHub Issues**: Feature requests and bugs
- **Email**: dev@chatly.app
- **Documentation**: docs.chatly.app

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) - Beautiful UI framework
- [Firebase](https://firebase.google.com) - Backend infrastructure
- [Unsplash](https://unsplash.com) - Free wallpapers
- [Perspective API](https://perspectiveapi.com) - Toxicity detection
- [RevenueCat](https://www.revenuecat.com) - Subscription management
- All open-source contributors and package maintainers

---

> "The best messaging app is the one that respects your privacy while keeping you connected." - Chatly Team

**Let's build something amazing! 🚀**

[![Build Status](https://github.com/yourusername/chatly/actions/workflows/build-apk.yml/badge.svg)](https://github.com/yourusername/chatly/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
```
