# ChillBills

A modern expense tracking application built with FastAPI (backend) and Flutter (frontend). ChillBills helps you manage your expenses and budgets with a clean, intuitive interface.

## Project Structure

```
.
├── backend/                # FastAPI backend service
│   ├── app/               # Application code
│   ├── logs/             # Application logs
│   ├── main.py           # Entry point
│   └── README.md         # Backend documentation
│
└── expense_tracker/      # Flutter frontend application
    ├── lib/              # Application code
    ├── assets/          # Static assets
    └── README.md        # Frontend documentation
```

## Getting Started

1. Start the backend service:
   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   uvicorn main:app --reload
   ```

2. Start the Flutter frontend:
   ```bash
   cd expense_tracker
   flutter pub get
   flutter run
   ```

## Features

- User authentication (register/login)
- Profile management
- Expense tracking
- Budget management
- Expense analytics
- Secure API endpoints
- Beautiful and responsive UI

## Development

- Backend API documentation is available at `http://localhost:8000/docs`
- The Flutter frontend runs on port 3000 by default
