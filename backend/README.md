# ChillBills Backend API

A FastAPI-based backend service for the ChillBills expense tracking application.

## Features

- User Authentication (JWT-based)
- Expense Management (CRUD operations)
- Expense Analytics and Insights
- MongoDB Integration
- Comprehensive Error Handling
- CORS Support
- Detailed Logging

## Prerequisites

- Python 3.8+
- MongoDB 4.4+
- pip (Python package manager)

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd backend
```

2. Create and activate a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Create a `.env` file in the root directory with the following variables:
```env
MONGODB_URL=mongodb://localhost:27017
DATABASE_NAME=chillbills
SECRET_KEY=your-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

## Running the Application

1. Start MongoDB:
```bash
mongod
```

2. Run the FastAPI server:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`

## API Documentation

After starting the server, you can access:
- Interactive API documentation: `http://localhost:8000/docs`
- Alternative API documentation: `http://localhost:8000/redoc`

### Main Endpoints

#### Authentication
- `POST /token`: Login and get access token
- `POST /users`: Create new user
- `GET /users/me`: Get current user profile

#### Expenses
- `GET /expenses`: List all expenses
- `POST /expenses`: Create new expense
- `GET /expenses/{id}`: Get specific expense
- `PUT /expenses/{id}`: Update expense
- `DELETE /expenses/{id}`: Delete expense

#### Analytics
- `GET /expenses/insights`: Get expense insights and analytics

## Data Models

### User
```python
{
    "username": str,
    "email": str,
    "password": str (hashed)
}
```

### Expense
```python
{
    "id": str,
    "amount": float,
    "description": str,
    "category": str (enum),
    "date": datetime,
    "user_id": str
}
```

### Categories
- food
- transportation
- entertainment
- shopping
- utilities
- health
- education
- other

## Error Handling

The API implements comprehensive error handling:
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 422: Validation Error
- 500: Internal Server Error

## Security

- JWT-based authentication
- Password hashing using bcrypt
- CORS middleware
- Input validation using Pydantic
- Environment variable configuration

## Development

### Project Structure
```
backend/
├── app/
│   ├── api/
│   │   └── endpoints.py
│   ├── core/
│   │   ├── config.py
│   │   └── database.py
│   ├── models/
│   │   ├── user.py
│   │   └── expense.py
│   └── utils/
│       ├── auth.py
│       └── logging.py
├── main.py
├── requirements.txt
└── README.md
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Testing

Run tests using pytest:
```bash
pytest
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
