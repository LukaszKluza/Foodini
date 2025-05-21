from enum import Enum


class Token(str, Enum):
    ACCESS = "access"
    REFRESH = "refresh"
    REVOKED = "revoked"
