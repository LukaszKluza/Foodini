import logging
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from backend.users.user_router import user_router
import psycopg2
from fastapi.middleware.cors import CORSMiddleware


app = FastAPI()
app.include_router(user_router)
logger = logging.getLogger("uvicorn.error")
logger.setLevel(logging.ERROR)

app.add_middleware(
    CORSMiddleware,
    allow_origins="*",
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)


@app.exception_handler(psycopg2.OperationalError)
@app.exception_handler(OSError)
async def db_connection_error_handler(request: Request, exc: Exception):
    logger.error(f"Database connection error: {str(exc)}")

    return JSONResponse(
        status_code=500,
        content={"error": "Database connection failed", "detail": str(exc)},
    )


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/health")
async def health_check():
    return {"status": "ok"}
