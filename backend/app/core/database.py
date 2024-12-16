import motor.motor_asyncio
from .config import settings

client = motor.motor_asyncio.AsyncIOMotorClient(settings.MONGODB_URL)
db = client[settings.DB_NAME]

async def test_db_connection():
    try:
        await client.admin.command('ping')
        return True
    except Exception as e:
        print(f"Database connection error: {str(e)}")
        return False
