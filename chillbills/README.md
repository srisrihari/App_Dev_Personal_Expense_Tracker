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

### ChillBills - Expense Tracking App

A modern, user-friendly expense tracking application built with Flutter.

### Features

- User Authentication
- Expense Management (Add, Edit, Delete)
- Expense Categories
- Expense Analytics and Insights
- Beautiful Material Design UI
- Dark/Light Theme Support
- Responsive Layout
- Offline Data Support
- Interactive Charts and Visualizations

### Screenshots

[Add screenshots of your app here]

### Prerequisites

- Flutter SDK 3.1.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Android SDK for Android deployment
- Xcode for iOS deployment

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd chillbills
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Project Structure

```
lib/
├── main.dart
├── app.dart
├── models/
│   ├── user.dart
│   └── expense.dart
├── providers/
│   ├── auth_provider.dart
│   └── expense_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── expenses/
│   │   ├── add_expense_screen.dart
│   │   ├── edit_expense_screen.dart
│   │   └── expense_list_screen.dart
│   └── insights/
│       └── insights_screen.dart
├── services/
│   └── api_service.dart
├── utils/
│   ├── constants.dart
│   └── theme.dart
└── widgets/
    ├── expense_card.dart
    ├── category_picker.dart
    └── charts/
        ├── expense_pie_chart.dart
        └── expense_line_chart.dart
```

### Architecture

The app follows a Provider-based architecture with the following components:

- **Models**: Data classes that represent the app's data structures
- **Providers**: State management using the Provider package
- **Screens**: UI components and business logic
- **Services**: API communication and data persistence
- **Utils**: Helper functions and constants
- **Widgets**: Reusable UI components

### Features in Detail

#### Authentication
- Secure login and registration
- JWT token management
- Persistent session management

#### Expense Management
- Add new expenses with title, amount, category, and date
- Edit existing expenses
- Delete expenses with confirmation
- Categorize expenses
- Date selection

#### Analytics
- Total expenses overview
- Category-wise expense distribution
- Monthly trends
- Interactive charts
- Expense insights

#### UI/UX
- Material Design 3
- Responsive layout
- Smooth animations
- Error handling with user feedback
- Loading indicators
- Pull-to-refresh
- Swipe-to-delete

### Dependencies

- `provider`: ^6.0.5 - State management
- `http`: ^1.1.0 - API communication
- `shared_preferences`: ^2.2.2 - Local storage
- `fl_chart`: ^0.65.0 - Charts and graphs
- `intl`: ^0.19.0 - Internationalization and formatting
- `google_fonts`: ^6.1.0 - Custom fonts
- `curved_navigation_bar`: ^1.0.3 - Bottom navigation
- `uuid`: ^4.2.1 - Unique ID generation

### API Integration

The app communicates with a FastAPI backend server. The base URL can be configured in `lib/services/api_service.dart`.

#### API Endpoints Used:
- Authentication: `/token`
- User Management: `/users`
- Expenses: `/expenses`
- Analytics: `/expenses/insights`

### State Management

The app uses Provider for state management with two main providers:
- `AuthProvider`: Handles user authentication state
- `ExpenseProvider`: Manages expense data and operations

### Error Handling

- Comprehensive error handling for API calls
- User-friendly error messages
- Offline support with error states
- Form validation
- Network error handling

### Testing

Run tests using:
```bash
flutter test
```

### Building for Production

1. Android:
```bash
flutter build apk --release
```

2. iOS:
```bash
flutter build ios --release
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

### Known Issues

- [List any known issues or limitations]

### Future Improvements

- [ ] Add budget tracking
- [ ] Implement notifications
- [ ] Add export functionality
- [ ] Support for multiple currencies
- [ ] Cloud backup
- [ ] Widget for home screen

### License

This project is licensed under the MIT License - see the LICENSE file for details.

### Acknowledgments

- Flutter team for the amazing framework
- All the package authors
- [Add any other acknowledgments]
