from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import logging
from app.api.endpoints import router
from app.core.database import test_db_connection
from app.utils.logging import setup_logging

# Setup logging
logger = setup_logging()

# Create FastAPI app
app = FastAPI(
    title="ChillBills API",
    description="Backend API for the ChillBills expense tracking application",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(router)

# Startup event
@app.on_event("startup")
async def startup_event():
    logger.info("Starting up the application")
    if await test_db_connection():
        logger.info("Successfully connected to the database")
    else:
        logger.error("Failed to connect to the database")
        raise Exception("Database connection failed")

# Error handling middleware
@app.middleware("http")
async def error_handling_middleware(request: Request, call_next):
    try:
        return await call_next(request)
    except Exception as e:
        logger.error(f"Unhandled error: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal Server Error")
