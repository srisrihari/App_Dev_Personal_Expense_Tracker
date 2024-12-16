from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime
from enum import Enum

class ExpenseCategory(str, Enum):
    food = "food"
    transportation = "transportation"
    entertainment = "entertainment"
    shopping = "shopping"
    utilities = "utilities"
    health = "health"
    education = "education"
    other = "other"

class ExpenseBase(BaseModel):
    amount: float = Field(..., gt=0)
    description: str = ""
    category: ExpenseCategory = ExpenseCategory.other
    date: datetime

    @validator('date')
    def validate_date(cls, v):
        if isinstance(v, str):
            try:
                return datetime.fromisoformat(v)
            except ValueError:
                raise ValueError('Invalid date format. Use ISO format (YYYY-MM-DDTHH:MM:SS)')
        return v

class ExpenseCreate(ExpenseBase):
    pass

class ExpenseUpdate(ExpenseBase):
    amount: Optional[float] = Field(None, gt=0)
    description: Optional[str] = None
    category: Optional[ExpenseCategory] = None
    date: Optional[datetime] = None

class Expense(ExpenseBase):
    id: str
    user_id: str

    class Config:
        allow_population_by_field_name = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }
