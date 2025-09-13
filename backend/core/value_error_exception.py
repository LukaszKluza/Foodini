class ValueErrorException(Exception):
    def __init__(self, detail: str = "Inappropriate value"):
        self.detail = detail