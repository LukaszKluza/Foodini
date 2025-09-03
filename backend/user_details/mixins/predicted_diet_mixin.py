from pydantic import model_validator


class PredictedDietMixin:
    @model_validator(mode="after")
    def check_predictions_sum(cls, values):
        pass
