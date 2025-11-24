from typing import Any, Optional


class NotFoundInDatabaseException(Exception):
    def __init__(self, detail: str = "Not found in Database", code: Optional[Any] = None):
        self.detail = detail
        self.code = code
