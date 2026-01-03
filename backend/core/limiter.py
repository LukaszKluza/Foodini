from fastapi import Request
from slowapi import Limiter


def user_rate_limit_key(request: Request):
    return request.query_params.get("user_id", request.client.host)


def user_target_date_key(request: Request):
    base = user_rate_limit_key(request)
    target_day = request.query_params.get("day") or "no-day"
    return f"{base}|{target_day}"


limiter = Limiter(key_func=user_rate_limit_key)
