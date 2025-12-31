import redis.asyncio as aioredis
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncEngine


async def check_db(engine: AsyncEngine) -> dict:
    try:
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        return {"status": "ok"}
    except Exception as e:
        return {"status": "down", "error": str(e)}


async def check_redis(redis: aioredis.Redis) -> dict:
    try:
        pong = await redis.ping()
        if pong:
            return {"status": "ok"}
        return {"status": "down", "error": "PING failed"}
    except Exception as e:
        return {"status": "down", "error": str(e)}
