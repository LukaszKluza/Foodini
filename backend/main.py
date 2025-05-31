import logging

import psycopg2
from fastapi import FastAPI, Request, HTTPException, status
from fastapi.exception_handlers import http_exception_handler
from fastapi.middleware.cors import CORSMiddleware
from redis.exceptions import ConnectionError as RedisConnectionError
from starlette.templating import Jinja2Templates
from starlette.exceptions import HTTPException as StarletteHTTPException

from backend.settings import config
from backend.user_details.user_details_router import user_details_router
from backend.users.user_router import user_router

app = FastAPI()
app.include_router(user_router)
app.include_router(user_details_router)
logger = logging.getLogger("uvicorn.error")
logger.setLevel(logging.ERROR)

app.add_middleware(
    CORSMiddleware,
    allow_origins="*",
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "X-Error-Code"],
)

templates = Jinja2Templates(directory="backend/templates")


@app.exception_handler(StarletteHTTPException)
async def custom_404_handler(request: Request, exc: StarletteHTTPException):
    if exc.status_code == 404:
        return templates.TemplateResponse(
            "404.html",
            {"request": request, "redirect_path": config.FRONTEND_URL},
            status_code=404,
        )
    return await http_exception_handler(request, exc)


@app.exception_handler(psycopg2.OperationalError)
@app.exception_handler(OSError)
async def db_connection_error_handler(request: Request, exc: Exception):
    logger.error(f"Database connection error: {str(exc)}")

    raise HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Server connection failed",
    )


@app.exception_handler(RedisConnectionError)
async def redis_connection_error_handler(request: Request, exc: Exception):
    logger.error(f"Redis connection error: {str(exc)}")

    raise HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Server connection failed",
    )


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/health")
async def health_check():
    return {"status": "ok"}
