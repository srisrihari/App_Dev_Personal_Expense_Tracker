# ChillBills Backend

This is the backend service for the ChillBills application, built with FastAPI and MongoDB.

## Project Structure

```
backend/
├── app/
│   ├── api/
│   │   └── endpoints.py      # API route handlers
│   ├── core/
│   │   ├── config.py        # Configuration settings
│   │   └── database.py      # Database connection
│   ├── models/
│   │   ├── user.py         # User-related models
│   │   └── expense.py      # Expense and Budget models
│   └── utils/
│       ├── auth.py         # Authentication utilities
│       └── logging.py      # Logging configuration
├── logs/                   # Application logs
├── main.py                # Application entry point
├── requirements.txt       # Python dependencies
└── README.md             # This file
```

## Setup

1. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Create a `.env` file in the root directory with the following variables:
   ```
   MONGO_URI=mongodb://localhost:27017
   DATABASE_NAME=chillbills
   JWT_SECRET_KEY=your-secret-key
   ADMIN_CLEAR_PASSWORD=your-admin-password
   ```

4. Run the application:
   ```bash
   uvicorn main:app --reload
   ```

The API will be available at `http://localhost:8000`. API documentation is available at `http://localhost:8000/docs`.
