from pydantic import BaseModel, EmailStr, Field, ConfigDict
import re

class User(BaseModel):
    username: str = Field(
        ..., 
        min_length=3, 
        max_length=50, 
        pattern=r'^[a-zA-Z0-9_]+$',
        description="Username must be 3-50 characters long, containing only letters, numbers, and underscores"
    )
    email: EmailStr
    password: str = Field(
        ..., 
        min_length=6, 
        max_length=100,
        description="Password must be at least 6 characters long"
    )
    model_config = ConfigDict(
        from_attributes=True,
        extra='forbid',  
        str_strip_whitespace=True  
    )

    @classmethod
    def validate_username(cls, v):
        if not re.match(r'^[a-zA-Z0-9_]+$', v):
            raise ValueError("Username can only contain letters, numbers, and underscores")
        return v

    @classmethod
    def validate_email(cls, v):
        return v

    @classmethod
    def validate_password(cls, v):
        return v

class UserProfileResponse(BaseModel):
    username: str
    email: str

class LoginResponse(BaseModel):
    access_token: str
    token_type: str
    user_id: str
    username: str
    email: str

class ClearUsersRequest(BaseModel):
    confirmation: str
    admin_password: str
