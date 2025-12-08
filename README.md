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
