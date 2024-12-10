from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId
import bcrypt

app = FastAPI()

# MongoDB connection
client = AsyncIOMotorClient("mongodb://localhost:27017")  # Update with your MongoDB connection string
db = client.expense_tracker

# Models
class User(BaseModel):
    username: str
    email: str
    password: str  # Password should be hashed

class Expense(BaseModel):
    id: Optional[str] = None
    user_id: str
    amount: float
    category: str
    date: str

# Security
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Routes
@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = await db.users.find_one({"username": form_data.username})
    if user and bcrypt.checkpw(form_data.password.encode('utf-8'), user['password']):
        return {"access_token": form_data.username, "token_type": "bearer"}
    raise HTTPException(status_code=400, detail="Incorrect username or password")

@app.post("/users/")
async def create_user(user: User):
    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    user_dict = user.dict()
    user_dict['password'] = hashed_password
    await db.users.insert_one(user_dict)
    return user

@app.post("/expenses/", response_model=Expense)
async def create_expense(expense: Expense, token: str = Depends(oauth2_scheme)):
    expense_dict = expense.dict()
    result = await db.expenses.insert_one(expense_dict)
    expense.id = str(result.inserted_id)
    return expense

@app.get("/expenses/", response_model=List[Expense])
async def read_expenses(token: str = Depends(oauth2_scheme)):
    expenses = await db.expenses.find().to_list(100)
    for expense in expenses:
        expense['id'] = str(expense['_id'])  # Convert ObjectId to string
    return expenses

@app.put("/expenses/{expense_id}", response_model=Expense)
async def update_expense(expense_id: str, expense: Expense, token: str = Depends(oauth2_scheme)):
    update_result = await db.expenses.update_one(
        {"_id": ObjectId(expense_id)},
        {"$set": expense.dict(exclude_unset=True)}
    )
    if update_result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Expense not found")
    expense.id = expense_id
    return expense

@app.delete("/expenses/{expense_id}")
async def delete_expense(expense_id: str, token: str = Depends(oauth2_scheme)):
    delete_result = await db.expenses.delete_one({"_id": ObjectId(expense_id)})
    if delete_result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Expense not found")
    return {"detail": "Expense deleted successfully"}

# ... additional routes can be added as needed ...