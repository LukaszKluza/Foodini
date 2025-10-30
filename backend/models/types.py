from decimal import Decimal

from sqlalchemy.types import Numeric, TypeDecorator


class FloatAsNumeric(TypeDecorator):
    impl = Numeric(10, 2)
    cache_ok = True

    def process_bind_param(self, value, dialect):
        if value is None:
            return None
        return Decimal(str(value))

    def process_result_value(self, value, dialect):
        if value is None:
            return None
        return float(value)
