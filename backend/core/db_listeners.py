from datetime import datetime

from sqlalchemy import event


def update_timestamps(mapper, connection, target):
    target.updated_at = datetime.now()


def register_timestamp_listeners(models):
    for model in models:
        event.listen(model, "before_update", update_timestamps)
