# MindOra 🧠

[![Flutter Version](https://img.shields.io/badge/Flutter-3.8.1+-02569B.svg?style=flat&logo=flutter)](https://flutter.dev/)
[![Node.js Version](https://img.shields.io/badge/Node.js-18.0+-339933.svg?style=flat&logo=node.js)](https://nodejs.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> A comprehensive cross-platform mental health application designed to provide personalized mental wellness support, tracking, and professional care coordination.

## 🌟 Overview

MindOra is a full-stack mental health platform that combines AI-powered insights, professional therapist integration, and comprehensive wellness tracking to support users on their mental health journey. The application features a Flutter-based mobile client and a robust Node.js backend with Supabase integration.

## ✨ Features

### 🎯 Core Features

- **Mood Tracking & Analytics** - Advanced mood visualization with FL Chart integration
- **AI-Powered Chatbot** - Google Generative AI for personalized mental health support
- **Digital Journal** - Secure journaling with image attachments and privacy controls
- **Sleep Monitoring** - Comprehensive sleep pattern tracking and insights
- **Stress Management** - Evidence-based stress reduction tools and techniques
- **Therapist Network** - Professional therapist discovery and appointment booking
- **Community Forum** - Peer support and discussion platform
- **Task Management** - Mental health-focused todo system with reminders

### 🔧 Technical Features

- **Cross-Platform** - iOS, Android, and Web support
- **Real-time Notifications** - Smart notification system for wellness reminders
- **Secure Authentication** - Supabase-powered user management
- **Offline Support** - Local storage with Hive for offline functionality
- **Modern UI/UX** - Custom Poppins typography and Material Design 3

## 🏗️ Architecture

```text
MindOra/
├── mindora/                    # Flutter Mobile Application
│   ├── lib/
│   │   ├── main.dart          # Application entry point
│   │   ├── appointment/       # Therapist booking system
│   │   ├── backend/           # API integration layer
│   │   ├── chatbot/           # AI chatbot interface
│   │   ├── dashboard/         # Main dashboard UI
│   │   ├── forum/             # Community features
│   │   ├── journal/           # Digital journaling
│   │   ├── login/             # Authentication flows
│   │   ├── mood/              # Mood tracking system
│   │   ├── navbar/            # Navigation components
│   │   ├── profile/           # User profile management
│   │   ├── services/          # Core services layer
│   │   ├── settings/          # Application settings
│   │   ├── sleep/             # Sleep tracking
│   │   ├── stress/            # Stress management tools
│   │   ├── therapist/         # Therapist directory
│   │   ├── todo_list/         # Task management
│   │   ├── utils/             # Helper utilities
│   │   └── widgets/           # Reusable UI components
│   ├── assets/                # Images and static resources
│   ├── fonts/                 # Custom typography (Poppins)
│   └── platform files/        # iOS, Android, Web configurations
└── server/                     # Node.js Backend API
    ├── index.js               # Express server entry point
    ├── DB/                    # Database configuration
    └── Route/                 # API route handlers
```

## 🛠️ Technology Stack

### Frontend (Mobile App)

- **Framework**: Flutter 3.8.1+
- **Language**: Dart
- **State Management**: Built-in Flutter state management
- **UI Components**: Material Design 3, Custom widgets
- **Charts**: FL Chart for data visualization
- **Typography**: Google Fonts (Poppins)
- **Storage**: Hive (local), Supabase (cloud)
- **Authentication**: Supabase Auth
- **AI Integration**: Google Generative AI
- **Notifications**: Awesome Notifications

### Backend (API Server)

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: PostgreSQL via Supabase
- **Authentication**: Supabase Auth
- **Email**: Nodemailer
- **Security**: bcrypt for password hashing
- **CORS**: Express CORS middleware

### Third-Party Integrations

- **Supabase**: Backend-as-a-Service (Database, Auth, Storage)
- **Google AI**: Generative AI for chatbot functionality
- **Awesome Notifications**: Advanced notification system

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK**: 3.8.1 or higher
- **Dart SDK**: Included with Flutter
- **Node.js**: 18.0 or higher
- **PostgreSQL**: Via Supabase (cloud) or local installation
- **Android Studio / Xcode**: For mobile development

### Environment Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/hasnat0006/SDP.git
   cd MindOra
   ```

2. **Configure Environment Variables**

   ```bash
   # In mindora/ directory, create .env file
   cp .env.example .env
   # Add your API keys and configuration
   ```

### 📱 Flutter App Setup

1. **Navigate to the Flutter app directory**

   ```bash
   cd mindora
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Flutter icons**

   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **Run the application**

   ```bash
   # For debug mode
   flutter run --debug
   
   # For release mode
   flutter run --release
   
   # For specific platform
   flutter run -d chrome      # Web
   flutter run -d emulator    # Android Emulator
   flutter run -d simulator   # iOS Simulator
   ```

### 🖥️ Backend Server Setup

1. **Navigate to the server directory**

   ```bash
   cd server
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Configure environment variables**

   ```bash
   # Create .env file with required configuration
   cp .env.example .env
   ```

4. **Start the development server**

   ```bash
   npm start
   ```

## 📚 API Documentation

The backend server provides RESTful APIs for:

- **Authentication**: User registration, login, password reset
- **Mood Tracking**: CRUD operations for mood entries
- **Journal Management**: Secure journal entry handling
- **Appointment System**: Therapist booking and management
- **Chat Integration**: AI chatbot conversation handling
- **Forum Features**: Community post and interaction management

API endpoints are available at `http://localhost:3000` (default) when running locally.

## 🧪 Testing

### Flutter Tests

```bash
cd mindora
flutter test
```

### Backend Tests

```bash
cd server
npm test
```

## 📦 Building for Production

### Android APK

```bash
cd mindora
flutter build apk --release
```

### Web Build

```bash
cd mindora
flutter build web --release
```

## 🤝 Contributing

We welcome contributions to MindOra! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- **Flutter**: Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- **Node.js**: Use ESLint configuration provided
- **Commits**: Use [Conventional Commits](https://www.conventionalcommits.org/)

