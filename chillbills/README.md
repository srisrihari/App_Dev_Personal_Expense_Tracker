# ChillBills - Expense Tracking App

A modern, user-friendly expense tracking application built with Flutter and FastAPI.

## Features

- **User Authentication**: Simple username-based authentication system
- **Expense Management**: Add, edit, and delete expenses with categories
- **Visual Insights**: View expense breakdowns with beautiful pie charts
- **Curved Navigation**: Sleek curved navigation bar for easy screen switching
- **Category Management**: Flexible string-based categories for expenses
- **Profile Management**: User profile with settings and logout functionality

## Tech Stack

- **Frontend**: Flutter
- **Backend**: FastAPI
- **Database**: MongoDB
- **State Management**: Provider
- **Charts**: fl_chart
- **Navigation**: curved_navigation_bar

## Getting Started

1. Clone the repository:
```bash
git clone <repository-url>
cd chillbills
```

2. Install dependencies:
```bash
flutter pub get
```

3. Make sure the FastAPI backend is running at `http://localhost:8000`

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
│   ├── auth/       # Authentication screens
│   ├── dashboard/  # Main dashboard
│   ├── expenses/   # Expense management
│   ├── insights/   # Analytics and charts
│   └── profile/    # User profile
├── services/       # API services
└── utils/          # Helper functions
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Frontend README

# ChillBills Flutter App

A modern, cross-platform expense management application built with Flutter.

## Technology Stack

- **Framework**: Flutter
- **State Management**: Provider
- **HTTP Client**: http package
- **Local Storage**: shared_preferences
- **Charts**: fl_chart
- **UI Components**: Material Design

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── expense.dart
│   └── user.dart
├── screens/                     # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── expenses/
│   │   ├── add_expense_screen.dart
│   │   └── expense_list_screen.dart
│   ├── insights/
│   │   └── insights_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── providers/                   # State management
│   ├── auth_provider.dart
│   └── expense_provider.dart
├── services/                    # API services
│   └── api_service.dart
└── widgets/                     # Reusable widgets
    ├── expense_card.dart
    └── chart_widgets.dart
```

## Features

### Expense Management
- Add, edit, and delete expenses
- Categorize expenses
- Track spending patterns
- Multi-currency support

### Analytics & Insights
- Monthly spending overview
- Category-wise breakdown
- Visual charts and graphs
- Spending trends

### User Experience
- Clean, modern UI
- Responsive design
- Dark/Light theme
- Cross-platform support

### Security
- Secure token storage
- Data encryption
- Input validation
- Error handling

## Setup and Installation

1. **Prerequisites**
   - Flutter SDK
   - Android Studio / Xcode
   - VS Code (recommended)

2. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd chillbills
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## Development

### Code Style
- Follow Flutter style guide
- Use meaningful variable names
- Document public APIs
- Implement error handling

### State Management
Using Provider pattern for:
- User authentication state
- Expense data
- Theme settings
- App configuration

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test
```

### Building

#### Android
```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# App Bundle
flutter build appbundle
```

#### iOS
```bash
# Requires MacOS and Xcode
flutter build ios

# Archive for App Store
flutter build ipa
```

#### Linux
```bash
flutter build linux
```

### Environment Configuration

Create `.env` file:
```env
API_URL=http://localhost:8000
ENABLE_LOGGING=true
```

## UI Components

### Screens
1. **Authentication**
   - Login
   - Registration
   - Password Reset

2. **Dashboard**
   - Expense Summary
   - Recent Transactions
   - Quick Actions

3. **Expenses**
   - Add/Edit Expense
   - Expense List
   - Category Filter

4. **Analytics**
   - Monthly Overview
   - Category Charts
   - Trend Analysis

5. **Profile**
   - User Settings
   - Preferences
   - Account Management

### Themes
- Light Theme
- Dark Theme
- Custom Color Schemes

## Error Handling

```dart
try {
  // API calls
} on NetworkException catch (e) {
  showErrorDialog('Network Error', e.message);
} on ValidationException catch (e) {
  showErrorDialog('Validation Error', e.message);
} catch (e) {
  showErrorDialog('Error', 'An unexpected error occurred');
}
```

## Performance Optimization

- Lazy loading of images
- Caching of API responses
- Efficient state management
- Memory leak prevention

## Deployment

### Android
1. Update `android/app/build.gradle`
2. Configure signing
3. Build release APK
4. Test on real devices
5. Deploy to Play Store

### iOS
1. Update `ios/Runner.xcodeproj`
2. Configure certificates
3. Build release IPA
4. Test on real devices
5. Deploy to App Store

### Linux
1. Configure Linux desktop settings
2. Build and package
3. Test on target platforms
4. Distribute package

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## Troubleshooting

### Common Issues
1. Build Errors
   - Clean project: `flutter clean`
   - Get dependencies: `flutter pub get`
   - Update Flutter: `flutter upgrade`

2. Runtime Errors
   - Check API configuration
   - Verify environment setup
   - Review error logs

3. UI Issues
   - Check device compatibility
   - Verify widget tree
   - Test different screen sizes

## License

MIT License - see LICENSE file for details
