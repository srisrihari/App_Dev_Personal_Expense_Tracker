# ChillBills - Expense Management Application

## Table of Contents
1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Frontend Implementation](#frontend-implementation)
4. [Backend Implementation](#backend-implementation)
5. [Database Schema](#database-schema)
6. [API Documentation](#api-documentation)
7. [Features](#features)
8. [Security](#security)
9. [Installation](#installation)
10. [Deployment](#deployment)

## Overview

ChillBills is a comprehensive expense management application designed to help users track, analyze, and manage their personal finances. The application provides real-time expense tracking, category-based organization, visual analytics, and detailed financial insights.

### Key Features
- User authentication and profile management
- Real-time expense tracking and categorization
- Visual analytics and financial insights
- Category-based expense organization
- Monthly and yearly expense summaries
- Multi-platform support (Android, iOS, Linux)

## System Architecture

### High-Level Architecture
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Flutter App    │◄───►│   FastAPI       │◄───►│   MongoDB       │
│  (Frontend)     │     │   (Backend)     │     │   (Database)    │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### Low-Level Architecture
```
Frontend (Flutter)
├── Presentation Layer
│   ├── Screens
│   │   ├── Dashboard
│   │   ├── Expenses
│   │   ├── Analytics
│   │   └── Profile
│   └── Widgets
├── Business Logic
│   ├── Providers
│   └── Services
└── Data Layer
    ├── Models
    └── Repositories

Backend (FastAPI)
├── API Layer
│   ├── Routes
│   └── Endpoints
├── Service Layer
│   ├── Authentication
│   └── Business Logic
└── Data Layer
    ├── Models
    └── Database
```

## Frontend Implementation

### Technology Stack
- **Framework**: Flutter
- **State Management**: Provider
- **HTTP Client**: http package
- **Charts**: fl_chart
- **Local Storage**: shared_preferences

### Key Components

1. **Screens**
   - `DashboardScreen`: Main interface showing expense overview
   - `AddExpenseScreen`: Form for adding/editing expenses
   - `InsightsScreen`: Visual analytics and statistics
   - `ProfileScreen`: User profile management

2. **Models**
   - `Expense`: Represents expense data structure
   - `User`: User profile information
   - `ExpenseCategory`: Expense categorization

3. **Providers**
   - `ExpenseProvider`: Manages expense state
   - `AuthProvider`: Handles authentication state
   - `UserProvider`: Manages user profile state

## Backend Implementation

### Technology Stack
- **Framework**: FastAPI
- **Database**: MongoDB
- **ORM**: MongoEngine
- **Authentication**: JWT

### Key Components

1. **API Endpoints**
   - `/auth`: Authentication endpoints
   - `/expenses`: Expense management
   - `/users`: User profile management
   - `/analytics`: Data analytics

2. **Models**
   ```python
   class Expense(Base):
       id: str
       title: str
       amount: float
       category: str
       date: datetime
       user_id: str
   ```

3. **Services**
   - Authentication Service
   - Expense Management Service
   - Analytics Service

## Database Schema

```json
// Users Collection
{
    "_id": ObjectId,
    "email": String,
    "hashed_password": String,
    "full_name": String,
    "created_at": Date
}

// Expenses Collection
{
    "_id": ObjectId,
    "user_id": ObjectId,
    "title": String,
    "amount": Number,
    "category": String,
    "date": Date,
    "created_at": Date
}
```

## API Documentation

### Authentication
- `POST /auth/login`: User login
- `POST /auth/register`: User registration
- `POST /auth/refresh`: Refresh access token

### Expenses
- `GET /expenses`: List user expenses
- `POST /expenses`: Create new expense
- `PUT /expenses/{id}`: Update expense
- `DELETE /expenses/{id}`: Delete expense

### Analytics
- `GET /analytics/monthly`: Monthly expense summary
- `GET /analytics/category`: Category-wise analysis
- `GET /analytics/trends`: Expense trends

## Features

### Expense Management
- Add, edit, and delete expenses
- Categorize expenses
- Attach receipts (future feature)
- Set recurring expenses (future feature)

### Analytics
- Monthly spending overview
- Category-wise breakdown
- Spending trends
- Budget tracking

### User Profile
- Profile management
- Preferences settings
- Notification settings (future feature)
- Currency preferences

## Security

1. **Authentication**
   - JWT-based authentication
   - Secure password hashing
   - Token refresh mechanism

2. **Data Protection**
   - HTTPS encryption
   - Input validation
   - SQL injection prevention
   - XSS protection

## Installation

### Prerequisites
- Flutter SDK
- Python 3.8+
- MongoDB
- Node.js (for development)

### Frontend Setup
```bash
# Clone repository
git clone [repository-url]

# Install dependencies
flutter pub get

# Run application
flutter run
```

### Backend Setup
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run server
uvicorn main:app --reload
```

## Database Setup

1. Install MongoDB:
```bash
sudo apt update
sudo apt install mongodb
```

2. Start MongoDB service:
```bash
sudo systemctl start mongodb
sudo systemctl enable mongodb
```

3. Configure database connection in `.env`:
```
MONGODB_URL=mongodb://localhost:27017
DATABASE_NAME=chillbills
```

## Deployment

### Frontend Deployment
1. Build for different platforms:
   ```bash
   # Android
   flutter build apk --release

   # iOS
   flutter build ios --release

   # Linux
   flutter build linux --release
   ```

### Backend Deployment
1. Set up environment variables
2. Configure database connection
3. Set up web server (e.g., Nginx)
4. Configure SSL certificates
5. Deploy using Docker (recommended)

```yaml
# docker-compose.yml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - MONGODB_URL=mongodb://db:27017
      - DATABASE_NAME=chillbills
    depends_on:
      - db
  
  db:
    image: mongo:latest
```

---

This documentation provides a comprehensive overview of the ChillBills application. For specific implementation details, refer to the codebase and inline documentation.
