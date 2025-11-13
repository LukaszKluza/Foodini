import psycopg2
from fastapi import FastAPI, HTTPException, Request, status
from fastapi.exception_handlers import http_exception_handler
from fastapi.middleware.cors import CORSMiddleware
from redis.exceptions import ConnectionError as RedisConnectionError
from slowapi.errors import RateLimitExceeded
from starlette.exceptions import HTTPException as StarletteHTTPException
from starlette.staticfiles import StaticFiles
from starlette.templating import Jinja2Templates

from backend.core.limiter import limiter
from backend.core.logger import logger
from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.core.value_error_exception import ValueErrorException
from backend.daily_summary.daily_summary_router import daily_summary_router
from backend.diet_generation.diet_generation_router import diet_generation_router
from backend.meals.meal_router import meal_router
from backend.settings import config
from backend.user_details.calories_prediction_router import calories_prediction_router
from backend.user_details.user_details_router import user_details_router
from backend.users.user_router import user_router

app = FastAPI()
app.include_router(user_router)
app.include_router(user_details_router)
app.include_router(calories_prediction_router)
app.include_router(diet_generation_router)
app.include_router(daily_summary_router)
app.include_router(meal_router)


app.add_middleware(
    CORSMiddleware,
    allow_origins="*",
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "X-Error-Code"],
)


app.mount("/v1/static/meals-icon", StaticFiles(directory="db/pictures_meals"), name="static")

app.state.limiter = limiter

templates = Jinja2Templates(directory="backend/templates")


@app.exception_handler(RateLimitExceeded)
async def rate_limit_exceeded_handler(request: Request, exc: RateLimitExceeded):
    raise HTTPException(
        status_code=status.HTTP_429_TOO_MANY_REQUESTS,
        detail=f"Rate limit exceeded, only {exc.limit.limit} request allowed. Try again in later.",
    )


@app.exception_handler(NotFoundInDatabaseException)
async def db_not_found_handler(request: Request, exc: NotFoundInDatabaseException):
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail=exc.detail,
    )


@app.exception_handler(ValueErrorException)
async def value_error_exception_handler_handler(request: Request, exc: ValueErrorException):
    raise HTTPException(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        detail=exc.detail,
    )


@app.exception_handler(StarletteHTTPException)
async def custom_404_handler(request: Request, exc: StarletteHTTPException):
    if exc.status_code == status.HTTP_404_NOT_FOUND:
        return templates.TemplateResponse(
            "404.html",
            {"request": request, "redirect_path": config.FRONTEND_URL},
            status_code=status.HTTP_404_NOT_FOUND,
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
