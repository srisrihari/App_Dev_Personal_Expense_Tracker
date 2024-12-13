from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime, timedelta
from jose import JWTError, jwt
import bcrypt
import logging
from bson import ObjectId

app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB setup
MONGO_URL = "mongodb://localhost:27017"
client = AsyncIOMotorClient(MONGO_URL)
db = client.expense_tracker

# OAuth2 setup
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Set up logging
logging.basicConfig(level=logging.INFO)

# Models
class User(BaseModel):
    username: str
    email: str
    password: str

class Expense(BaseModel):
    id: Optional[str] = None
    user_id: str
    amount: float
    category: str
    date: str

# JWT Settings
SECRET_KEY = "your-secret-key-keep-it-secret"  # In production, use a secure secret key
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials",
            )
        return user_id
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
        )

# Routes
@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    try:
        user = await db.users.find_one({"username": form_data.username})
        if not user or not bcrypt.checkpw(form_data.password.encode('utf-8'), user["password"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect username or password"
            )
        
        token_data = {"sub": str(user["_id"])}
        access_token = create_access_token(token_data)
        
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user_id": str(user["_id"])
        }
    except Exception as e:
        logging.error(f"Error in login: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

@app.post("/users/", response_model=User)
async def create_user(user: User):
    try:
        # Check if username already exists
        if await db.users.find_one({"username": user.username}):
            raise HTTPException(status_code=400, detail="Username already registered")
        
        # Hash password
        hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
        user_dict = user.dict()
        user_dict["password"] = hashed_password
        
        result = await db.users.insert_one(user_dict)
        user_dict["_id"] = str(result.inserted_id)
        return user_dict
    except Exception as e:
        logging.error(f"Error in create_user: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

@app.post("/expenses/", response_model=Expense)
async def create_expense(expense: Expense, user_id: str = Depends(verify_token)):
    try:
        expense_dict = expense.dict(exclude={"id"})
        expense_dict["user_id"] = user_id
        result = await db.expenses.insert_one(expense_dict)
        expense_dict["id"] = str(result.inserted_id)
        return expense_dict
    except Exception as e:
        logging.error(f"Error in create_expense: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

@app.get("/expenses/", response_model=List[Expense])
async def get_expenses(user_id: str = Depends(verify_token)):
    try:
        cursor = db.expenses.find({"user_id": user_id})
        expenses = []
        async for doc in cursor:
            doc["id"] = str(doc.pop("_id"))
            expenses.append(doc)
        return expenses
    except Exception as e:
        logging.error(f"Error in get_expenses: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

@app.put("/expenses/{expense_id}", response_model=Expense)
async def update_expense(expense_id: str, expense: Expense, user_id: str = Depends(verify_token)):
    try:
        expense_dict = expense.dict(exclude={"id"})
        expense_dict["user_id"] = user_id
        
        result = await db.expenses.update_one(
            {"_id": ObjectId(expense_id), "user_id": user_id},
            {"$set": expense_dict}
        )
        
        if result.modified_count == 0:
            raise HTTPException(status_code=404, detail="Expense not found")
            
        expense_dict["id"] = expense_id
        return expense_dict
    except Exception as e:
        logging.error(f"Error in update_expense: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

@app.delete("/expenses/{expense_id}")
async def delete_expense(expense_id: str, user_id: str = Depends(verify_token)):
    try:
        result = await db.expenses.delete_one({
            "_id": ObjectId(expense_id),
            "user_id": user_id
        })
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Expense not found")
        return {"message": "Expense deleted successfully"}
    except Exception as e:
        logging.error(f"Error in delete_expense: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")