import psycopg2
import sqlalchemy
from fastapi import FastAPI, HTTPException, Request, status
from fastapi.exception_handlers import http_exception_handler
from fastapi.middleware.cors import CORSMiddleware
from redis.exceptions import RedisError
from slowapi.errors import RateLimitExceeded
from starlette.exceptions import HTTPException as StarletteHTTPException
from starlette.responses import JSONResponse
from starlette.staticfiles import StaticFiles
from starlette.templating import Jinja2Templates

from backend.barcode_scanning.barcode_scanning_router import barcode_scanning_router
from backend.core.limiter import limiter
from backend.core.logger import logger
from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.core.value_error_exception import ValueErrorException
from backend.daily_summary.daily_summary_router import daily_summary_router
from backend.diet_generation.diet_generation_router import diet_generation_router
from backend.meals.meal_router import meal_router
from backend.open_food_facts.open_food_facts_router import open_food_facts_router
from backend.settings import config
from backend.user_details.calories_prediction_router import calories_prediction_router
from backend.user_details.user_details_router import user_details_router
from backend.user_statistics.user_statistics_router import user_statistics_router
from backend.users.user_router import user_router

app = FastAPI(docs_url="/docs", redoc_url=None)
app.include_router(user_router)
app.include_router(user_details_router)
app.include_router(calories_prediction_router)
app.include_router(diet_generation_router)
app.include_router(daily_summary_router)
app.include_router(meal_router)
app.include_router(user_statistics_router)
app.include_router(open_food_facts_router)
app.include_router(barcode_scanning_router)


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
        detail={
            "date": f"{request.query_params.get('date')}",
            "message": f"Rate limit exceeded, only {exc.limit.limit} request allowed. Try again later.",
        },
    )


@app.exception_handler(NotFoundInDatabaseException)
async def db_not_found_handler(request: Request, exc: NotFoundInDatabaseException):
    code = getattr(exc, "code", None)
    try:
        code = code.value if hasattr(code, "value") else code
    except Exception:
        code = str(code) if code is not None else None
    return JSONResponse(
        status_code=status.HTTP_404_NOT_FOUND,
        content={"detail": exc.detail, "code": code},
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
async def db_connection_error_handler(request: Request, exc: psycopg2.OperationalError):
    logger.error(f"Database connection error: {str(exc)}")

    raise HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Server connection failed",
    )


@app.exception_handler(sqlalchemy.exc.OperationalError)
async def db_operational_error_handler(request: Request, exc: sqlalchemy.exc.OperationalError):
    logger.error(f"Database connection error: {str(exc)}")

    raise HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Server connection failed",
    )


@app.exception_handler(sqlalchemy.exc.DBAPIError)
async def db_api_error_handler(request: Request, exc: sqlalchemy.exc.DBAPIError):
    logger.error(f"Database connection error: {str(exc)}")

    raise HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Server connection failed",
    )


@app.exception_handler(RedisError)
async def redis_connection_error_handler(request: Request, exc: Exception):
    logger.error(f"Redis connection error: {str(exc)}")

    raise HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Server connection failed",
    )


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    logger.exception(f"Unhandled exception: {str(exc)}")

    raise HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Internal Server Error",
    )


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/health")
async def health_check():
    return {"status": "ok"}
