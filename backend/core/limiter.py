from datetime import datetime

from fastapi import Request
from slowapi import Limiter


def user_rate_limit_key(request: Request):
    return request.query_params.get("user_id", request.client.host)


def user_target_date_key(request: Request):
    base = user_rate_limit_key(request)
    target_day = request.query_params.get("day") or "no-day"
    return f"{base}|{target_day}"


def user_triggered_date_key(request: Request):
    base = user_rate_limit_key(request)
    server_date = datetime.now().strftime("%Y-%m-%d")
    return f"{base}|{server_date}"


limiter = Limiter(key_func=user_rate_limit_key, default_limits=["5 per second", "1000 per day"])
