class AppConfig {
  // Use 10.0.2.2 for Android emulator to access localhost on host machine
  static const String baseUrl = 'http://10.0.2.2:8000';

  // API Endpoints
  static const String loginEndpoint = '$baseUrl/token/';
  static const String registerEndpoint = '$baseUrl/users';
  static const String profileEndpoint = '$baseUrl/profile';
  static const String expensesEndpoint = '$baseUrl/expenses';
  static const String budgetsEndpoint = '$baseUrl/budgets';
}
