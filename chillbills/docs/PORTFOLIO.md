# ChillBills - Gamified Expense Tracker

## Project Overview
ChillBills is a gamified expense tracking mobile application built with Flutter and FastAPI. It transforms the mundane task of expense tracking into an engaging experience through gamification elements.

## Key Features
1. **User Authentication**
   - Secure registration and login
   - JWT-based authentication
   - Profile management

2. **Expense Management**
   - Add, edit, and delete expenses
   - Category-based organization
   - Date and amount tracking
   - Real-time updates

3. **Visual Analytics**
   - Category-wise breakdown
   - Monthly spending trends
   - Interactive charts
   - Budget tracking

4. **Gamification**
   - Achievement system
   - Monthly challenges
   - Progress tracking
   - Rewards system

## Technical Stack
### Frontend (Flutter)
- Material Design UI
- Provider state management
- Local storage with SharedPreferences
- HTTP client for API communication
- Chart libraries for analytics

### Backend (FastAPI)
- RESTful API architecture
- JWT authentication
- MongoDB integration
- CORS middleware
- Input validation

### Database (MongoDB)
- User management
- Expense tracking
- Achievement storage
- Budget management

## Code Highlights

### 1. Clean Architecture
```dart
// Provider Pattern for State Management
class ExpenseProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Expense> _expenses = [];
  
  Future<void> fetchExpenses() async {
    _expenses = await _apiService.getExpenses();
    notifyListeners();
  }
}
```

### 2. Secure Authentication
```dart
// JWT Token Management
class ApiService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
```

### 3. Interactive UI
```dart
// Category Breakdown Chart
Widget _buildCategoryBreakdown(List<Expense> expenses) {
  return PieChart(
    PieChartData(
      sections: _generateChartSections(expenses),
      centerSpaceRadius: 40,
    ),
  );
}
```

## Development Process
1. **Planning Phase**
   - Requirement analysis
   - UI/UX design
   - Architecture planning
   - Task breakdown

2. **Implementation**
   - Week 1: Core features
   - Week 2: Analytics & UI
   - Week 3: Gamification

3. **Testing & Deployment**
   - Unit testing
   - Integration testing
   - User testing
   - Deployment preparation

## Challenges & Solutions
1. **State Management**
   - Challenge: Complex state across screens
   - Solution: Provider pattern with ChangeNotifier

2. **Data Persistence**
   - Challenge: Offline functionality
   - Solution: SharedPreferences for local storage

3. **Performance**
   - Challenge: Chart rendering optimization
   - Solution: Cached data and lazy loading

## Future Enhancements
1. Social features for expense sharing
2. AI-powered spending insights
3. Custom achievement creation
4. Multi-currency support
5. Budget automation tools

## Screenshots
[Add actual screenshots of your app here]

## Conclusion
ChillBills demonstrates the effective use of modern mobile development practices and gamification principles to create an engaging user experience. The project showcases clean architecture, secure authentication, and interactive data visualization while maintaining code quality and performance.
