# ChillBills Technical Documentation

## System Architecture

### Complete System Overview
```
┌─────────────────────────────────────────────────────────────────┐
│                        Client Layer                             │
├─────────────┬─────────────┬─────────────────┬─────────────────┤
│ Android App │   iOS App   │   Linux App     │    Web App      │
│  (Flutter)  │  (Flutter)  │    (Flutter)    │   (Flutter)     │
└─────┬───────┴──────┬──────┴────────┬────────┴────────┬────────┘
      │              │               │                  │
      └──────────────┴───────────────┴──────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Communication Layer                          │
├─────────────────┬───────────────────────┬─────────────────────┤
│    REST API     │      WebSocket        │     GraphQL         │
│    (FastAPI)    │  (Real-time updates)  │  (Complex queries)  │
└────────┬────────┴──────────┬────────────┴──────────┬──────────┘
         │                   │                       │
         └───────────────────┴───────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Service Layer                              │
├──────────────┬────────────────┬───────────────┬───────────────┤
│  Auth Service│ Expense Service│ User Service  │ Analytics     │
│  (JWT + BCrypt)│(CRUD + Valid.) │(Profile Mgmt.)│ (Insights)   │
└──────┬───────┴───────┬────────┴──────┬────────┴──────┬────────┘
       │               │               │               │
       └───────────────┴───────────────┴───────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Data Layer                                 │
├────────────────┬─────────────────┬──────────────┬─────────────┤
│   MongoDB      │     Redis       │  File Store  │  Backups    │
│  (Main DB)     │   (Cache)       │  (Assets)    │ (Daily)     │
└────────────────┴─────────────────┴──────────────┴─────────────┘
```

### Database Schema (MongoDB)
```javascript
// Users Collection
{
  "_id": ObjectId,
  "email": String,  // unique index
  "hashed_password": String,
  "full_name": String,
  "created_at": ISODate,
  "updated_at": ISODate,
  "last_login": ISODate,
  "is_active": Boolean,
  "preferences": Object
}

// Expenses Collection
{
  "_id": ObjectId,
  "user_id": ObjectId,  // index
  "title": String,
  "amount": Decimal128,
  "category": String,  // enum: ['food', 'transportation', 'entertainment', 'shopping', 'utilities', 'health', 'education', 'other']
  "description": String,
  "date": ISODate,  // index
  "created_at": ISODate,
  "updated_at": ISODate,
  "currency": String,  // default: 'USD'
  "tags": Array,
  "metadata": Object
}

// Categories Collection
{
  "_id": ObjectId,
  "name": String,  // unique index
  "icon": String,
  "color": String,
  "created_at": ISODate
}

// Budgets Collection
{
  "_id": ObjectId,
  "user_id": ObjectId,  // index
  "category_id": ObjectId,
  "amount": Decimal128,
  "period": String,  // enum: ['daily', 'weekly', 'monthly', 'yearly']
  "start_date": ISODate,
  "end_date": ISODate,
  "created_at": ISODate
}

// Indexes
db.expenses.createIndex({ "user_id": 1 })
db.expenses.createIndex({ "date": 1 })
db.expenses.createIndex({ "category": 1 })
db.budgets.createIndex({ "user_id": 1, "category_id": 1 })
```

### Authentication Flow
```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  Client  │     │  FastAPI │     │ Database │     │  Redis   │
└────┬─────┘     └────┬─────┘     └────┬─────┘     └────┬─────┘
     │                │                 │                │
     │  Login Request │                 │                │
     │───────────────>│                 │                │
     │                │                 │                │
     │                │ Query User Data │                │
     │                │───────────────->│                │
     │                │                 │                │
     │                │ Return User Data│                │
     │                │<────────────────│                │
     │                │                 │                │
     │                │ Verify Password │                │
     │                │─────────┐       │                │
     │                │         │       │                │
     │                │<────────┘       │                │
     │                │                 │                │
     │                │ Generate Token  │                │
     │                │─────────┐       │                │
     │                │         │       │                │
     │                │<────────┘       │                │
     │                │                 │                │
     │                │  Store Token    │                │
     │                │───────────────────────────────-->│
     │                │                 │                │
     │   Return Token │                 │                │
     │<───────────────│                 │                │
     │                │                 │                │
```

### Data Flow (Expense Creation)
```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  Widget  │     │ Provider │     │  Service │     │   API    │
└────┬─────┘     └────┬─────┘     └────┬─────┘     └────┬─────┘
     │                │                 │                │
     │ Create Expense │                 │                │
     │───────────────>│                 │                │
     │                │                 │                │
     │                │ Validate Data   │                │
     │                │─────────┐       │                │
     │                │         │       │                │
     │                │<────────┘       │                │
     │                │                 │                │
     │                │ Call Service    │                │
     │                │───────────────->│                │
     │                │                 │                │
     │                │                 │ API Request    │
     │                │                 │───────────────>│
     │                │                 │                │
     │                │                 │    Response    │
     │                │                 │<───────────────│
     │                │                 │                │
     │                │  Update State   │                │
     │                │─────────┐       │                │
     │                │         │       │                │
     │                │<────────┘       │                │
     │                │                 │                │
     │ Update UI      │                 │                │
     │<───────────────│                 │                │
     │                │                 │                │
```

### State Management (Provider)
```
┌─────────────────────────────────────────────┐
│                 Provider Tree               │
└─────────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
┌───────────────┐         ┌──────────────┐
│ AuthProvider  │         │ ThemeProvider│
└───────┬───────┘         └──────┬───────┘
        │                        │
        ▼                        ▼
┌───────────────┐         ┌──────────────┐
│ExpenseProvider│         │LocalProvider │
└───────┬───────┘         └──────┬───────┘
        │                        │
        ▼                        ▼
┌───────────────┐         ┌──────────────┐
│ UserProvider  │         │ErrorProvider │
└───────────────┘         └──────────────┘
```

### API Endpoints Structure
```
api/
├── v1/
│   ├── auth/
│   │   ├── POST /login
│   │   ├── POST /register
│   │   └── POST /refresh-token
│   │
│   ├── expenses/
│   │   ├── GET    /
│   │   ├── POST   /
│   │   ├── GET    /{id}
│   │   ├── PUT    /{id}
│   │   └── DELETE /{id}
│   │
│   ├── categories/
│   │   ├── GET    /
│   │   └── GET    /{id}/expenses
│   │
│   ├── users/
│   │   ├── GET    /me
│   │   └── PUT    /me
│   │
│   └── analytics/
│       ├── GET /monthly
│       ├── GET /category
│       └── GET /trends
│
└── health/
    └── GET /
```

### Security Implementation
```
┌─────────────────────────────────────────────┐
│              Security Layers                │
└─────────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
┌───────────────┐         ┌──────────────┐
│    HTTPS      │         │     CORS     │
└───────┬───────┘         └──────┬───────┘
        │                        │
        ▼                        ▼
┌───────────────┐         ┌──────────────┐
│  JWT Tokens   │         │  Rate Limit  │
└───────┬───────┘         └──────┬───────┘
        │                        │
        ▼                        ▼
┌───────────────┐         ┌──────────────┐
│Input Validation│         │ SQL Injection│
└───────┬───────┘         └──────┬───────┘
        │                        │
        ▼                        ▼
┌───────────────┐         ┌──────────────┐
│Password Hashing│         │   Logging    │
└───────────────┘         └──────────────┘
```

### Caching Strategy
```
┌─────────────────────────────────────────────┐
│              Caching Layers                 │
└─────────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
┌───────────────┐         ┌──────────────┐
│ Memory Cache  │         │ Redis Cache  │
│  (Provider)   │         │  (Server)    │
└───────┬───────┘         └──────┬───────┘
        │                        │
        ▼                        ▼
┌───────────────┐         ┌──────────────┐
│ Local Storage │         │ API Response │
│  (Flutter)    │         │   Cache      │
└───────────────┘         └──────────────┘
```

### Error Handling
```dart
// Frontend Error Handling
try {
  // API call or operation
} on NetworkException catch (e) {
  // Handle network errors
  ErrorHandler.showNetworkError(e);
} on ValidationException catch (e) {
  // Handle validation errors
  ErrorHandler.showValidationError(e);
} on AuthenticationException catch (e) {
  // Handle auth errors
  ErrorHandler.showAuthError(e);
} catch (e) {
  // Handle unknown errors
  ErrorHandler.showGenericError(e);
}

// Backend Error Handling
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    return JSONResponse(
        status_code=422,
        content={"detail": exc.errors()}
    )

@app.exception_handler(DatabaseError)
async def database_exception_handler(request, exc):
    return JSONResponse(
        status_code=500,
        content={"detail": "Database error occurred"}
    )
```

### Performance Optimization
```
┌─────────────────────────────────────────────┐
│           Performance Strategy              │
└─────────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
┌───────────────┐         ┌──────────────┐
│ Lazy Loading  │         │ API Caching  │
└───────┬───────┘         └──────┬───────┘
        │                        │
        ▼                        ▼
┌───────────────┐         ┌──────────────┐
│Image Optimiz. │         │Query Optimiz.│
└───────┬───────┘         └──────┬───────┘
        │                        │
        ▼                        ▼
┌───────────────┐         ┌──────────────┐
│ State Mgmt.   │         │ DB Indexing  │
└───────────────┘         └──────────────┘
```

### Testing Strategy
```
┌─────────────────────────────────────────────┐
│              Testing Layers                 │
└─────────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
┌───────────────┐         ┌──────────────┐
│  Unit Tests   │         │    E2E Tests │
└───────┬───────┘         └──────┬───────┘
        │                        │
        ▼                        ▼
┌───────────────┐         ┌──────────────┐
│Widget Tests   │         │Integration   │
└───────┬───────┘         └──────┬───────┘
        │                        │
        ▼                        ▼
┌───────────────┐         ┌──────────────┐
│Golden Tests   │         │Performance   │
└───────────────┘         └──────────────┘
```

## CI/CD Pipeline
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Commit    │ ──> │    Build    │ ──> │    Test     │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Analyze   │ ──> │   Deploy    │ ──> │  Monitor    │
└─────────────┘     └─────────────┘     └─────────────┘
