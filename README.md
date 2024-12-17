# ChillBills - Personal Finance Management

A modern expense tracking application built with FastAPI (backend) and Flutter (frontend). ChillBills helps you manage your expenses and budgets with a clean, intuitive interface and powerful analytics.

## Project Structure

```
.
├── backend/                # FastAPI backend service
│   ├── app/               # Application code
│   │   ├── api/          # API endpoints
│   │   ├── core/         # Core functionality
│   │   ├── db/           # Database models
│   │   └── services/     # Business logic
│   ├── tests/            # Backend tests
│   └── README.md         # Backend documentation
│
├── chillbills/           # Flutter frontend application
│   ├── lib/              # Application code
│   │   ├── models/       # Data models
│   │   ├── screens/      # UI screens
│   │   ├── providers/    # State management
│   │   └── services/     # API services
│   ├── assets/           # Static assets
│   └── README.md         # Frontend documentation
│
└── docs/                 # Project documentation
    ├── README.md         # Complete documentation
    └── ARCHITECTURE.md   # Technical architecture
```

## Key Features

- **Expense Management**
  - Add, edit, and delete expenses
  - Categorize expenses
  - Track spending patterns
  - Multi-currency support

- **Analytics & Insights**
  - Monthly spending overview
  - Category-wise breakdown
  - Visual charts and graphs
  - Spending trends

- **User Experience**
  - Clean, modern UI
  - Responsive design
  - Dark/Light theme
  - Cross-platform support

- **Security**
  - JWT authentication
  - Secure password handling
  - Data encryption
  - Input validation

## Getting Started

### Prerequisites
- Python 3.8+
- Flutter SDK
- PostgreSQL
- Node.js (for development)

### Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload
```

### Frontend Setup
```bash
cd chillbills
flutter pub get
flutter run
```

## Development

- Backend API documentation: `http://localhost:8000/docs`
- Frontend development server: `http://localhost:3000`

### API Testing
```bash
cd backend
pytest
```

### Flutter Testing
```bash
cd chillbills
flutter test
```

## Deployment

### Backend Deployment
```bash
cd backend
docker-compose up -d
```

### Frontend Deployment
```bash
cd chillbills
flutter build apk --release      # Android
flutter build ios --release      # iOS
flutter build linux --release    # Linux
```

## Documentation

- [Complete Documentation](docs/README.md)
- [Technical Architecture](docs/ARCHITECTURE.md)
- [Backend API Documentation](backend/README.md)
- [Frontend Documentation](chillbills/README.md)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
