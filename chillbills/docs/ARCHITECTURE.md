# ChillBills Technical Architecture

## System Components

### 1. Frontend Architecture (Flutter)

```
Frontend (Flutter)
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── expense.dart         # Expense model
│   │   └── user.dart           # User model
│   ├── screens/                 # UI screens
│   │   ├── dashboard/          # Dashboard screen
│   │   ├── expenses/           # Expense management
│   │   ├── insights/           # Analytics
│   │   └── profile/            # User profile
│   ├── providers/              # State management
│   │   ├── auth_provider.dart
│   │   └── expense_provider.dart
│   ├── services/               # API services
│   │   └── api_service.dart
│   └── widgets/                # Reusable widgets
└── test/                       # Unit tests
```

### 2. Backend Architecture (FastAPI)

```
Backend (FastAPI)
├── app/
│   ├── main.py                # App entry point
│   ├── api/                   # API endpoints
│   │   ├── auth.py           # Authentication
│   │   ├── expenses.py       # Expense management
│   │   └── users.py         # User management
│   ├── core/                 # Core functionality
│   │   ├── config.py        # Configuration
│   │   └── security.py      # Security utils
│   ├── db/                   # Database
│   │   ├── base.py          # Base models
│   │   └── session.py       # DB session
│   ├── models/              # SQLAlchemy models
│   └── schemas/             # Pydantic schemas
└── tests/                   # API tests
```

## Data Flow Diagrams

### 1. Authentication Flow

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│          │     │          │     │          │     │          │
│  User    │────►│  Flutter │────►│ FastAPI  │────►│   DB     │
│          │     │   App    │     │ Backend  │     │          │
│          │◄────│          │◄────│          │◄────│          │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
     │                                                   │
     │                                                   │
     └───────────────── JWT Token Flow ─────────────────┘
```

### 2. Expense Management Flow

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│          │     │          │     │          │     │          │
│  User    │────►│ Provider │────►│   API    │────►│   DB     │
│ Action   │     │  State   │     │ Service  │     │          │
│          │◄────│          │◄────│          │◄────│          │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
     │                │                │                │
     │                │                │                │
     └────────────── State Updates ───────────────────┘
```

## Component Interactions

### 1. Frontend-Backend Communication

```
┌─────────────────────┐
│    Flutter App      │
└─────────────────────┘
         │
         │ HTTP/HTTPS
         ▼
┌─────────────────────┐
│    API Gateway      │
└─────────────────────┘
         │
         │ Internal API
         ▼
┌─────────────────────┐
│  FastAPI Backend    │
└─────────────────────┘
         │
         │ SQL
         ▼
┌─────────────────────┐
│    PostgreSQL DB    │
└─────────────────────┘
```

### 2. State Management Flow

```
┌─────────────────┐     ┌─────────────────┐
│   UI Widgets    │     │    Providers    │
└─────────────────┘     └─────────────────┘
         │                      │
         │ User Actions         │ State Updates
         ▼                      ▼
┌─────────────────┐     ┌─────────────────┐
│   API Service   │     │  Local Storage  │
└─────────────────┘     └─────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────┐
│              Client Side                │
├─────────────────────────────────────────┤
│ - JWT Token Management                  │
│ - Secure Storage                        │
│ - Input Validation                      │
└─────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│            Communication                │
├─────────────────────────────────────────┤
│ - HTTPS                                 │
│ - SSL/TLS                               │
│ - API Key Authentication                │
└─────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│              Server Side                │
├─────────────────────────────────────────┤
│ - JWT Verification                      │
│ - Password Hashing                      │
│ - Rate Limiting                         │
│ - SQL Injection Prevention              │
└─────────────────────────────────────────┘
```

## Database Architecture

#### Data Storage
- **MongoDB**: NoSQL database for flexible schema and scalable data storage
- **Collections**: Users, Expenses, Categories, Budgets
- **Indexes**: Optimized for common queries and relationships
- **Data Validation**: Schema validation using MongoDB validators

#### Schema Design
```javascript
// Core Collections
db.users.insertOne({
    _id: ObjectId(),
    email: "user@example.com",
    hashed_password: "bcrypt_hash",
    created_at: new Date()
});

db.expenses.insertOne({
    _id: ObjectId(),
    user_id: ObjectId("user_id"),
    amount: NumberDecimal("50.00"),
    category: "food",
    description: "Lunch",
    date: new Date()
});
```

#### Data Access Patterns
- User authentication and profile management
- Expense tracking and categorization
- Budget monitoring and alerts
- Analytics and reporting

## Deployment Architecture

```
┌─────────────────────────────────────────┐
│            Load Balancer                │
└─────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│               Nginx                      │
└─────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│         Docker Containers               │
├──────────────┬──────────────┬──────────┤
│  FastAPI     │  PostgreSQL  │  Redis   │
│  Backend     │  Database    │  Cache   │
└──────────────┴──────────────┴──────────┘
```

This technical architecture document provides a detailed view of the system's components, their interactions, and the overall structure of the ChillBills application. Use this as a reference for understanding the system design and making architectural decisions.
