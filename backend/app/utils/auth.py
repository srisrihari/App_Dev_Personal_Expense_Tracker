from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from ..core.config import settings
from ..core.database import db
from bson import ObjectId
from ..models.user import User
from passlib.hash import bcrypt

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt

def verify_password(plain_password: str, hashed_password: str):
    return bcrypt.verify(plain_password, hashed_password)

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = await db.users.find_one({"username": username})
    if user is None:
        raise credentials_exception
        
    return str(user["_id"])

async def get_current_active_user(user_id: str = Depends(get_current_user)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # Find the user by ID and convert ObjectId to string
        user_data = await db.users.find_one({"_id": ObjectId(user_id)})
        
        if user_data is None:
            raise credentials_exception
        
        # Convert user data to User model
        user = User(
            username=user_data.get('username'),
            email=user_data.get('email'),
            password=user_data.get('password')  # Be careful with password handling
        )
        
        return user
    except Exception as e:
        raise credentials_exception
