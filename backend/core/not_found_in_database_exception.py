class NotFoundInDatabaseException(Exception):
    def __init__(self, detail: str = "Not found in Database"):
        self.detail = detail
