import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    PROJECT_NAME: str = "ChillBills API"
    PROJECT_VERSION: str = "1.0.0"
    MONGODB_URL: str = os.getenv("MONGO_URI", "mongodb://localhost:27017")
    DB_NAME: str = os.getenv("DATABASE_NAME", "chillbills")
    ADMIN_CLEAR_PASSWORD: str = os.getenv("ADMIN_CLEAR_PASSWORD", "")
    JWT_SECRET_KEY: str = os.getenv("JWT_SECRET_KEY", "your-secret-key")
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

settings = Settings()
