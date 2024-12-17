# ChillBills Backend

FastAPI-based backend service for the ChillBills expense management application.

## Technology Stack

- **Framework**: FastAPI
- **Database**: PostgreSQL
- **ORM**: SQLAlchemy
- **Authentication**: JWT
- **Testing**: pytest
- **Documentation**: Swagger/OpenAPI

## Project Structure

```
backend/
├── app/
│   ├── api/
│   │   ├── endpoints/
│   │   │   ├── auth.py
│   │   │   ├── expenses.py
│   │   │   └── users.py
│   │   └── deps.py
│   ├── core/
│   │   ├── config.py
│   │   ├── security.py
│   │   └── deps.py
│   ├── db/
│   │   ├── base.py
│   │   └── session.py
│   ├── models/
│   │   ├── expense.py
│   │   └── user.py
│   └── schemas/
│       ├── expense.py
│       └── user.py
├── tests/
│   ├── api/
│   ├── core/
│   └── conftest.py
├── alembic/
│   └── versions/
├── requirements.txt
└── main.py
```

## API Endpoints

### Authentication
```
POST /api/auth/login
POST /api/auth/register
POST /api/auth/refresh-token
```

### Expenses
```
GET    /api/expenses
POST   /api/expenses
GET    /api/expenses/{id}
PUT    /api/expenses/{id}
DELETE /api/expenses/{id}
```

### Users
```
GET    /api/users/me
PUT    /api/users/me
DELETE /api/users/me
```

### Analytics
```
GET    /api/analytics/monthly
GET    /api/analytics/category
GET    /api/analytics/trends
```

## Setup and Installation

1. **Create Virtual Environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   ```

2. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Environment Variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Database Setup**
   ```bash
   # Create database
   createdb chillbills

   # Run migrations
   alembic upgrade head
   ```

5. **Run Development Server**
   ```bash
   uvicorn main:app --reload
   ```

## Development

### Code Style
- Follow PEP 8 guidelines
- Use type hints
- Document functions and classes

### Running Tests
```bash
pytest
pytest --cov=app tests/
```

### Database Migrations
```bash
# Create migration
alembic revision --autogenerate -m "description"

# Apply migration
alembic upgrade head

# Rollback
alembic downgrade -1
```

## Deployment

### Using Docker
```bash
# Build image
docker build -t chillbills-backend .

# Run container
docker run -d -p 8000:8000 chillbills-backend
```

### Using Docker Compose
```bash
docker-compose up -d
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| DATABASE_URL | PostgreSQL connection URL | postgresql://user:pass@localhost/chillbills |
| SECRET_KEY | JWT secret key | None |
| ALGORITHM | JWT algorithm | HS256 |
| ACCESS_TOKEN_EXPIRE_MINUTES | Token expiry | 30 |

## API Documentation

- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Security

- JWT authentication
- Password hashing with bcrypt
- CORS middleware
- Rate limiting
- Input validation
- SQL injection prevention

## Error Handling

All API endpoints follow a consistent error response format:

```json
{
  "detail": {
    "msg": "Error message",
    "code": "ERROR_CODE"
  }
}
```

Common error codes:
- `AUTHENTICATION_ERROR`
- `VALIDATION_ERROR`
- `NOT_FOUND`
- `PERMISSION_DENIED`

## Contributing

1. Follow the project's code style
2. Write tests for new features
3. Update documentation
4. Create detailed pull requests

## License

MIT License - see LICENSE file for details
