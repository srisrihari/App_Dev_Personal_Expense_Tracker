from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordRequestForm
import logging
from datetime import datetime
from bson import ObjectId
from ..models.user import User, UserProfileResponse, LoginResponse, ClearUsersRequest
from ..models.expense import Expense, ExpenseCreate
from ..core.database import db
from ..utils.auth import create_access_token, get_current_user, get_current_active_user
from ..core.config import settings
from passlib.hash import bcrypt

router = APIRouter()
logger = logging.getLogger(__name__)

def get_password_hash(password: str):
    return bcrypt.hash(password)

def verify_password(plain_password: str, hashed_password: str):
    return bcrypt.verify(plain_password, hashed_password)

# User endpoints
@router.post("/users", response_model=UserProfileResponse)
@router.post("/users/", response_model=UserProfileResponse)
async def create_user(user: User):
    try:
        # Check if username already exists
        existing_username = await db.users.find_one({"username": user.username})
        if existing_username:
            raise HTTPException(status_code=400, detail="Username already exists")
        
        # Check if email already exists
        existing_email = await db.users.find_one({"email": user.email})
        if existing_email:
            raise HTTPException(status_code=400, detail="Email already exists")
        
        # Hash the password
        hashed_password = get_password_hash(user.password)
        
        # Prepare user data for insertion
        user_data = {
            "username": user.username,
            "email": user.email,
            "password": hashed_password
        }
        
        # Insert user into database
        result = await db.users.insert_one(user_data)
        user_data["_id"] = result.inserted_id
        
        # Return user profile response
        return UserProfileResponse(
            username=user.username,
            email=user.email
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating user: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal Server Error creating user")

@router.post("/token", response_model=LoginResponse)
@router.post("/token/", response_model=LoginResponse)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    try:
        # Find user by username
        user = await db.users.find_one({"username": form_data.username})
        
        if not user:
            raise HTTPException(
                status_code=401, 
                detail="Incorrect username or password"
            )
        
        stored_password = user.get('password')
        
        # Verify password
        if not verify_password(form_data.password, stored_password):
            raise HTTPException(
                status_code=401, 
                detail="Incorrect username or password"
            )
        
        # Create access token
        access_token = create_access_token(
            data={"sub": user['username']}
        )
        
        return LoginResponse(
            access_token=access_token,
            token_type="bearer",
            user_id=str(user['_id']),
            username=user['username'],
            email=user['email']
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Login error: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail="Authentication system error"
        )

@router.get("/profile", response_model=UserProfileResponse)
async def get_user_profile(user_id: str = Depends(get_current_user)):
    try:
        user = await db.users.find_one({"_id": ObjectId(user_id)})
        
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        return UserProfileResponse(
            username=user.get('username', ''),
            email=user.get('email', '')
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching user profile: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500, 
            detail="Internal Server Error"
        )

@router.delete("/users/me")
async def delete_user(
    user_id: str = Depends(get_current_user),
    current_user: User = Depends(get_current_active_user)
):
    try:
        # Validate user exists
        user = await db.users.find_one({"_id": ObjectId(user_id)})
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # Delete user's expenses
        expenses_result = await db.expenses.delete_many({"user_id": user_id})
        
        # Delete user account
        user_result = await db.users.delete_one({"_id": ObjectId(user_id)})
        
        # Log deletion details
        logger.info(f"User deleted: {current_user.username}")
        logger.info(f"Expenses deleted: {expenses_result.deleted_count}")
        
        return {
            "message": "User account and all associated data have been deleted successfully",
            "details": {
                "username": current_user.username,
                "email": current_user.email,
                "expenses_deleted": expenses_result.deleted_count
            }
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting user: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal Server Error deleting user account")

# Expense endpoints
@router.post("/expenses", response_model=Expense)
@router.post("/expenses/", response_model=Expense)
async def create_expense(
    expense: ExpenseCreate,
    user_id: str = Depends(get_current_user)
):
    try:
        # Validate and prepare expense data
        expense_data = expense.dict()
        expense_data["user_id"] = user_id
        
        # Convert string date to datetime if present
        if "date" in expense_data and isinstance(expense_data["date"], str):
            expense_data["date"] = datetime.fromisoformat(expense_data["date"])

        # Insert into database
        result = await db.expenses.insert_one(expense_data)
        
        if not result.inserted_id:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create expense"
            )

        # Fetch the created expense
        created_expense = await db.expenses.find_one({"_id": result.inserted_id})
        if not created_expense:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Created expense not found"
            )

        # Convert ObjectId to string and create Expense model
        created_expense["id"] = str(created_expense["_id"])
        del created_expense["_id"]
        
        # The date is already a datetime object from MongoDB
        return Expense(**created_expense)

    except ValueError as e:
        logger.error(f"Error creating expense: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Error creating expense: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error creating expense: {str(e)}"
        )

@router.get("/expenses", response_model=list[Expense])
@router.get("/expenses/", response_model=list[Expense])
async def get_expenses(user_id: str = Depends(get_current_user)):
    try:
        cursor = db.expenses.find({"user_id": user_id})
        expenses = []
        async for doc in cursor:
            # Convert MongoDB _id to string id
            doc["id"] = str(doc["_id"])
            del doc["_id"]
            # The date is already a datetime object from MongoDB
            expenses.append(Expense(**doc))
        return expenses
    except Exception as e:
        logger.error(f"Error fetching expenses: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/expenses/{expense_id}", response_model=Expense)
async def get_expense(expense_id: str, user_id: str = Depends(get_current_user)):
    try:
        expense = await db.expenses.find_one({
            "_id": ObjectId(expense_id),
            "user_id": user_id
        })
        
        if not expense:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Expense not found"
            )

        # Convert MongoDB _id to string id
        expense["id"] = str(expense["_id"])
        del expense["_id"]
        
        # The date is already a datetime object from MongoDB
        return Expense(**expense)

    except Exception as e:
        logger.error(f"Error fetching expense: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error fetching expense: {str(e)}"
        )

@router.put("/expenses/{expense_id}", response_model=Expense)
async def update_expense(
    expense_id: str,
    expense: Expense,
    user_id: str = Depends(get_current_user)
):
    try:
        # Check if expense exists and belongs to user
        existing = await db.expenses.find_one({
            "_id": ObjectId(expense_id),
            "user_id": user_id
        })
        
        if not existing:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Expense not found"
            )

        # Update the expense
        update_data = expense.dict(exclude={"id"})
        
        # Convert string date to datetime if present
        if "date" in update_data and isinstance(update_data["date"], str):
            update_data["date"] = datetime.fromisoformat(update_data["date"])

        result = await db.expenses.update_one(
            {"_id": ObjectId(expense_id)},
            {"$set": update_data}
        )

        if result.modified_count == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Expense not modified"
            )

        # Get updated expense
        updated = await db.expenses.find_one({"_id": ObjectId(expense_id)})
        updated["id"] = str(updated["_id"])
        del updated["_id"]
        
        # The date is already a datetime object from MongoDB
        return Expense(**updated)

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Error updating expense: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error updating expense: {str(e)}"
        )

@router.delete("/expenses/{expense_id}")
async def delete_expense(expense_id: str, user_id: str = Depends(get_current_user)):
    try:
        result = await db.expenses.delete_one({
            "_id": ObjectId(expense_id),
            "user_id": user_id
        })

        if result.deleted_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Expense not found"
            )

        return {"message": "Expense deleted successfully"}

    except Exception as e:
        logger.error(f"Error deleting expense: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error deleting expense: {str(e)}"
        )

# Admin endpoints
@router.post("/admin/clear-users")
async def clear_all_users(request: ClearUsersRequest):
    try:
        # Verify admin password
        if request.admin_password != settings.ADMIN_CLEAR_PASSWORD:
            raise HTTPException(status_code=403, detail="Invalid admin password")
        
        if request.confirmation.lower() != "confirm":
            raise HTTPException(status_code=400, detail="Confirmation not provided")
        
        # Delete all collections related to user data
        await db.users.delete_many({})
        await db.expenses.delete_many({})
        
        return {
            "message": "All user data has been cleared successfully",
            "collections_cleared": ["users", "expenses"]
        }
    except Exception as e:
        logger.error(f"Error clearing users: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal Server Error clearing user data")

# Expense insights endpoint
@router.get("/expense-insights", response_model=dict)
async def get_expense_insights(user_id: str = Depends(get_current_user)):
    try:
        # Get all expenses for the current user
        cursor = db.expenses.find({"user_id": user_id})
        expenses = []
        async for doc in cursor:
            # Convert MongoDB _id to string id
            doc["id"] = str(doc["_id"])
            del doc["_id"]
            # The date is already a datetime object from MongoDB
            expenses.append(Expense(**doc))
        
        if not expenses:
            return {
                "total_monthly_expense": 0,
                "average_monthly_expense": 0,
                "average_weekly_expense": 0,
                "daily_insights": []
            }
        
        # Calculate monthly insights
        current_month = datetime.now().month
        current_year = datetime.now().year
        monthly_expenses = [
            exp for exp in expenses 
            if exp.date.month == current_month and exp.date.year == current_year
        ]
        
        total_monthly_expense = sum(exp.amount for exp in monthly_expenses)
        average_monthly_expense = total_monthly_expense / max(len(monthly_expenses), 1)
        
        # Calculate weekly insights
        weekly_expenses = [
            exp for exp in expenses 
            if (datetime.now() - exp.date).days <= 7
        ]
        average_weekly_expense = sum(exp.amount for exp in weekly_expenses) / max(len(weekly_expenses), 1)
        
        # Daily insights with performance tracking
        daily_expenses = {}
        for exp in expenses:
            date_key = exp.date.date()
            daily_expenses[date_key] = daily_expenses.get(date_key, 0) + exp.amount
        
        # Sort daily expenses by date
        sorted_daily_expenses = sorted(daily_expenses.items())
        
        # Prepare daily insights with performance tracking
        daily_insights = []
        for i in range(1, len(sorted_daily_expenses)):
            prev_day, prev_amount = sorted_daily_expenses[i-1]
            curr_day, curr_amount = sorted_daily_expenses[i]
            
            # Calculate average of previous days
            avg_before_curr_day = sum(
                amount for day, amount in sorted_daily_expenses[:i]
            ) / i
            
            insight = {
                "date": curr_day.isoformat(),
                "amount": curr_amount,
                "performance": "below_average" if curr_amount < avg_before_curr_day else "above_average",
                "difference_percentage": abs((curr_amount - avg_before_curr_day) / avg_before_curr_day * 100) if avg_before_curr_day > 0 else 0
            }
            daily_insights.append(insight)
        
        return {
            "total_monthly_expense": total_monthly_expense,
            "average_monthly_expense": average_monthly_expense,
            "average_weekly_expense": average_weekly_expense,
            "daily_insights": daily_insights
        }
    except Exception as e:
        logger.error(f"Error fetching expense insights: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal Server Error fetching expense insights")
