# Flutter Posts - Clean Architecture Challenge

A Flutter mobile application demonstrating **Clean Architecture**, **BLoC state management**, and **native integration** using Pigeon. The app consumes the JSONPlaceholder API and implements native notifications for Android (Kotlin) and iOS (Swift).

---

## 📋 Project Overview

This project is a technical challenge focused on:
- Implementing **Clean Architecture** principles in Flutter
- Managing complex state with **BLoC/Cubit**
- Integrating native platform features using **Pigeon** (type-safe, no manual MethodChannel)
- Building a production-ready app with proper testing and code organization

The app allows users to browse posts from JSONPlaceholder, search and filter them, view comments, and like/unlike posts with native notification feedback.

---

## 🏗️ Architecture

### Clean Architecture

The project follows **Clean Architecture** with clear separation of concerns across three layers:

```
lib/
├── core/                    # Shared utilities
│   ├── di/                  # Dependency injection (GetIt)
│   ├── network/             # HTTP client (Dio)
│   ├── router/              # Navigation (GoRouter)
│   ├── theme/               # App theming
│   └── native/              # Pigeon integration
│
├── features/
│   ├── posts/
│   │   ├── data/            # Data sources, models, repositories
│   │   ├── domain/          # Entities, repositories, use cases
│   │   └── presentation/    # BLoC, Cubit, UI
│   │
│   ├── post_details/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── favorites/
│       ├── data/            # SharedPreferences persistence
│       ├── domain/
│       └── presentation/    # Global FavoritesCubit
```

### Layer Responsibilities

**Data Layer**
- Remote data sources (API calls via Dio)
- Local data sources (SharedPreferences)
- Data models with JSON serialization
- Repository implementations

**Domain Layer**
- Business entities (pure Dart objects)
- Repository interfaces
- Use cases (single responsibility business logic)

**Presentation Layer**
- BLoC/Cubit for state management
- UI widgets and pages
- Event/State definitions

### State Management

**BLoC Pattern** is used for complex features:
- `PostsBloc`: Manages posts list, pagination, refresh
- `PostDetailBloc`: Manages comments loading and refresh

**Cubit Pattern** for simpler state:
- `FavoritesCubit`: Global state for liked posts (persisted)
- `PostFilterCubit`: Local search query and filter type

**Cross-Screen State Sharing**
- `FavoritesCubit` is provided at the app root via `BlocProvider`
- Both `PostsPage` and `PostDetailPage` consume the same cubit instance
- Likes are persisted to `SharedPreferences` and survive app restarts
- State updates are reactive across all screens

---

## ✨ Features Implemented

### 📱 Posts List
- Infinite scroll pagination (10 posts per page)
- Pull-to-refresh
- Error handling with retry button
- Hero images from `picsum.photos`

### 🔍 Search & Filter
- **Local search**: Filters by post title or body (case-insensitive)
- **Filter options**: All / Liked / Not Liked
- Combined search + filter logic
- Real-time filtering without API calls

### 📄 Post Detail
- Full post content display
- Comments list with user avatars (`dicebear` API)
- Pull-to-refresh for comments
- Error handling with retry

### ❤️ Like System
- Like/unlike from both list and detail screens
- Visual feedback with cyan accent color
- **Native notification** triggered on like (Android & iOS)
- Persistent state using `SharedPreferences`

### 🎨 Modern UI
- Custom theme with Cyan/Teal accent (`#00BFA5`)
- Card-based design with shadows
- Collapsing header in detail view
- Responsive layouts

---

## 📲 Native Integration (Pigeon)

### Why Pigeon?

Pigeon generates **type-safe** platform channel code, eliminating manual `MethodChannel` boilerplate and runtime errors from type mismatches.

### Contract Definition

```dart
// pigeon/native_notification_api.dart
class NotificationPayload {
  final String postTitle;
  final String body;
}

@HostApi()
abstract class NativeNotificationApi {
  void showLikeNotification(NotificationPayload payload);
}
```

### Android Implementation (Kotlin)

**Main File**: `android/app/src/main/kotlin/com/example/flutter_posts/MainActivity.kt`

**Key Features:**
- **Notification Channel**: Creates a high-priority channel (`IMPORTANCE_HIGH`) for Android 8.0+ with vibration enabled
- **Runtime Permissions**: Requests `POST_NOTIFICATIONS` permission for Android 13+ (API 33)
- **Foreground & Background Support**: Notifications work in both app states
- **Configuration**:
  - `PRIORITY_HIGH` for immediate visibility
  - `CATEGORY_SOCIAL` for proper notification grouping
  - `VISIBILITY_PUBLIC` to show content on lock screen
  - `autoCancel(true)` to dismiss on tap

**Implementation Details:**
```kotlin
// Notification with high priority and visibility
val notification = NotificationCompat.Builder(this, channelId)
    .setSmallIcon(android.R.drawable.btn_star_big_on)
    .setContentTitle(payload.title)
    .setContentText(payload.body)
    .setPriority(NotificationCompat.PRIORITY_HIGH)
    .setCategory(NotificationCompat.CATEGORY_SOCIAL)
    .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
    .setAutoCancel(true)
    .build()
```

### iOS Implementation (Swift)

**Files**: 
- `ios/Runner/AppDelegate.swift` - App lifecycle and foreground handling
- `ios/Runner/NativeNotificationApiImpl.swift` - Notification logic

**Key Features:**
- **Foreground Notifications**: Implemented via `UNUserNotificationCenterDelegate`
- **Permission Handling**: Requests `.alert`, `.sound`, and `.badge` permissions
- **iOS 14+ Support**: Uses `.banner` presentation style for modern iOS
- **Background Support**: Notifications delivered even when app is in background

**Implementation Details:**

**AppDelegate.swift** - Enables foreground notifications:
```swift
override func userNotificationCenter(
  _ center: UNUserNotificationCenter,
  willPresent notification: UNNotification,
  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
) {
  if #available(iOS 14.0, *) {
    completionHandler([.banner, .sound])  // Modern banner style
  } else {
    completionHandler([.alert, .sound])   // Legacy alert style
  }
}
```

**NativeNotificationApiImpl.swift** - Notification creation:
```swift
func showNotification(payload: NotificationPayload) throws {
  let content = UNMutableNotificationContent()
  content.title = payload.title
  content.body = payload.body
  content.sound = .default
  
  let trigger = UNTimeIntervalNotificationTrigger(
    timeInterval: 1,
    repeats: false
  )
  
  let request = UNNotificationRequest(
    identifier: UUID().uuidString,
    content: content,
    trigger: trigger
  )
  
  UNUserNotificationCenter.current().add(request)
}
```

### Why This Matters

**Foreground Notifications** are not shown by default on iOS. The `userNotificationCenter(_:willPresent:withCompletionHandler:)` delegate method is crucial for displaying notifications when the app is active, providing a consistent user experience across both platforms.

---

## 🛠️ Pigeon Setup

### Code Generation Command

```bash
dart run pigeon \
  --input pigeon/native_notification_api.dart \
  --dart_out lib/core/native/native_notification_api.g.dart \
  --kotlin_out android/app/src/main/kotlin/com/example/flutter_posts/NativeNotificationApi.g.kt \
  --kotlin_package com.example.flutter_posts \
  --swift_out ios/Runner/NativeNotificationApi.g.swift \
  --package_name flutter_posts
```

### Generated Files
- `lib/core/native/native_notification_api.g.dart` - Dart bindings
- `android/.../NativeNotificationApi.g.kt` - Kotlin bindings
- `ios/Runner/NativeNotificationApi.g.swift` - Swift bindings

---

## 🚀 Setup & Run

### Requirements
- Flutter SDK: `>=3.8.1`
- Dart SDK: `>=3.8.1`
- Android Studio / Xcode for platform builds

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd flutter_posts

# Install dependencies
flutter pub get

# Run Pigeon code generation (if needed)
dart run pigeon --input pigeon/native_notification_api.dart \
  --dart_out lib/core/native/native_notification_api.g.dart \
  --kotlin_out android/app/src/main/kotlin/com/example/flutter_posts/NativeNotificationApi.g.kt \
  --kotlin_package com.example.flutter_posts \
  --swift_out ios/Runner/NativeNotificationApi.g.swift \
  --package_name flutter_posts

# Run the app
flutter run
```

### Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

---

## 🧪 Testing

### Test Coverage

**18 unit tests** covering critical business logic across both features:

**Posts Feature**
- `post_remote_datasource_test.dart` - API data fetching
- `post_repository_impl_test.dart` - Repository pattern
- `get_posts_usecase_test.dart` - Use case logic
- `posts_bloc_test.dart` - BLoC state transitions

**Post Details Feature**
- `post_details_remote_datasource_test.dart` - Comments API
- `post_details_repository_impl_test.dart` - Repository implementation
- `get_comments_usecase_test.dart` - Use case logic
- `post_detail_bloc_test.dart` - BLoC state management

### Testing Tools
- **`bloc_test`**: BLoC state testing with expectations
- **`mocktail`**: Mock generation for dependencies
- **`flutter_test`**: Core testing framework

### Test Structure
All tests follow the **Arrange-Act-Assert** pattern with consistent mock class definitions.

---

## 🤖 AI Usage

### Tools Used
- **ChatGPT**: General Flutter/Dart questions and architecture discussions
- **Antigravity (Google)**: Code generation, test scaffolding, and refactoring

### AI Contributions
- **Test generation**: After creating the initial test structure for posts manually, AI helped scaffold similar tests for post details
- **Code refactoring**: Assistance with converting mockito to mocktail for consistency
- **Documentation**: Helped structure and refine README sections
- **Debugging**: Suggestions for fixing lint errors and test failures

### Human Decisions
- **Architecture design**: Clean Architecture structure and layer separation
- **State management approach**: Choice of BLoC vs Cubit for different features
- **Feature implementation**: Core business logic and UI/UX decisions
- **Initial test structure**: First test suite for posts feature was manually designed
- **Native integration strategy**: Decision to use Pigeon over manual MethodChannel
- **Native implementation**: Complete Android (Kotlin) and iOS (Swift) notification code, including foreground/background support
- **Dependency injection**: GetIt setup and service registration

### Collaboration Model
The project demonstrates a **human-led, AI-assisted** workflow where architectural decisions, critical implementations, and **all native platform code** were human-driven, while AI accelerated repetitive tasks and provided suggestions for optimization.

---

## 🎥 Demo

### Expected Demo Video Content

1. **Posts List**
   - Scroll through paginated posts
   - Pull-to-refresh functionality
   - Search posts by typing in search bar
   - Toggle between filters (All / Liked / Not Liked)

2. **Post Detail**
   - Tap a post to view details
   - Scroll through comments
   - Pull-to-refresh comments

3. **Like Functionality**
   - Like a post from the list
   - **Native notification appears** (Android/iOS)
   - Navigate to detail, verify like state persists
   - Unlike from detail screen
   - Return to list, verify state updated

4. **Native Notification Evidence**
   - Clear visual of notification appearing in system tray
   - Notification content showing post title and body
   - Demonstration on both Android and iOS (if possible)

---

## 📦 Dependencies

### Core
- `flutter_bloc: ^9.1.1` - State management
- `dio: ^5.9.1` - HTTP client
- `go_router: ^17.0.1` - Navigation
- `get_it: ^9.2.0` - Dependency injection
- `equatable: ^2.0.7` - Value equality
- `shared_preferences: ^2.2.2` - Local persistence
- `pigeon: ^26.1.7` - Native communication

### Dev Dependencies
- `flutter_test` - Testing framework
- `bloc_test: ^10.0.0` - BLoC testing utilities
- `mocktail: ^1.0.4` - Mocking library
- `flutter_lints: ^5.0.0` - Linting rules

---

## 📝 Notes

- All network images use placeholder services (picsum.photos, dicebear)
- Notification permissions are requested at runtime
- Likes persist across app restarts via SharedPreferences

