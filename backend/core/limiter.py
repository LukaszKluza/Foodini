from fastapi import Request
from slowapi import Limiter


def user_rate_limit_key(request: Request):
    user = getattr(request.state, "user", None)
    if user and hasattr(user, "id"):
        return str(user.id)
    return request.client.host


limiter = Limiter(key_func=user_rate_limit_key)
