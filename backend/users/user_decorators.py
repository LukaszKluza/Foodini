from fastapi.params import Depends
from functools import wraps
from typing import Callable, Coroutine
from pydantic import EmailStr

from backend.users.user_repository import UserRepository, get_user_repository
from backend.users.user_validations import UserValidations
from backend.users.service.authorisation_service import AuthorizationService
from backend.settings import config


class UserDecorators:
    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository

    def requires_verified_user(user_arg_index: int):
        def decorator(func: Callable) -> Callable:
            @wraps(func)
            def wrapper(self, *args, **kwargs):
                user = args[user_arg_index]
                UserValidations.ensure_verified_user(user)
                return func(self, *args, **kwargs)

            return wrapper

        return decorator

    def requires_permission(token_id_index: int, request_id_index: int):
        def decorator(func: Callable) -> Callable:
            @wraps(func)
            def wrapper(self, *args, **kwargs):
                print(args, "CHUUUUUUUUUUUUUJ")
                UserValidations.check_user_permission(
                    args[token_id_index], args[request_id_index]
                )
                return func(self, *args, **kwargs)

            return wrapper

        return decorator

    def requires_password_change_allowed(user_arg_index: int):
        def decorator(func: Callable) -> Callable:
            @wraps(func)
            def wrapper(self, *args, **kwargs):
                user = args[user_arg_index]
                UserValidations.check_last_password_change_data_time(user)
                return func(self, *args, **kwargs)

            return wrapper

        return decorator

    def inject_user_by_email(email_arg_index: int):
        def decorator(func: Callable[..., Coroutine]) -> Callable[..., Coroutine]:
            @wraps(func)
            async def wrapper(self, *args, **kwargs):
                email_or_obj = args[email_arg_index]

                if isinstance(email_or_obj, str) and "@" in email_or_obj:
                    email = email_or_obj
                elif hasattr(email_or_obj, "email"):
                    email = email_or_obj.email
                else:
                    raise ValueError(
                        f"Cannot extract email from argument at index {email_arg_index}"
                    )

                user = await UserValidations.ensure_user_exists_by_email(
                    self.user_repository, email
                )
                new_args = (*args, user)
                return await func(self, *new_args, **kwargs)

            return wrapper

        return decorator

    def inject_user_by_token():
        def decorator(func: Callable[..., Coroutine]) -> Callable[..., Coroutine]:
            @wraps(func)
            async def wrapper(self, token: str, *args, **kwargs):
                token_data = await AuthorizationService.decode_url_safe_token(
                    token, kwargs.get("salt", config.NEW_ACCOUNT_SALT)
                )
                email = token_data.get("email")
                user = await UserValidations.ensure_user_exists_by_email(
                    self.user_repository, email
                )
                new_args = (*args, user)
                return await func(self, token, *new_args, **kwargs)

            return wrapper

        return decorator

    def inject_user_by_id(user_id_index: int):
        def decorator(func: Callable[..., Coroutine]) -> Callable[..., Coroutine]:
            @wraps(func)
            async def wrapper(self, *args, **kwargs):
                user_id = args[user_id_index]
                user = await UserValidations.ensure_user_exists_by_id(
                    self.user_repository, user_id
                )
                new_args = (*args, user)
                return await func(self, *new_args, **kwargs)

            return wrapper

        return decorator


def get_email_verification_service(
    user_repository: UserRepository = Depends(get_user_repository),
) -> UserDecorators:
    return UserDecorators(user_repository)
