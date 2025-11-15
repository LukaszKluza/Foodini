import uuid
from datetime import date

from backend.models import UserDetails
from backend.user_details.enums import (
    ActivityLevel,
    DietaryRestriction,
    DietIntensity,
    DietType,
    Gender,
    SleepQuality,
    StressLevel,
)

user_1 = UserDetails(
    id=1,
    user_id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a61"),
    gender=Gender.MALE,
    height_cm=180.0,
    weight_kg=65.0,
    date_of_birth=date(2002, 5, 15),
    diet_type=DietType.MUSCLE_GAIN,
    dietary_restrictions=[DietaryRestriction.LACTOSE],
    diet_goal_kg=70.0,
    meals_per_day=3,
    diet_intensity=DietIntensity.SLOW,
    activity_level=ActivityLevel.LIGHT,
    stress_level=StressLevel.MEDIUM,
    sleep_quality=SleepQuality.FAIR,
    muscle_percentage=45.0,
    water_percentage=55.0,
    fat_percentage=18.0,
)

user_2 = UserDetails(
    id=2,
    user_id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a62"),
    gender=Gender.FEMALE,
    height_cm=165.0,
    weight_kg=65.0,
    date_of_birth=date(1990, 3, 10),
    diet_type=DietType.FAT_LOSS,
    dietary_restrictions=[],
    diet_goal_kg=60.0,
    meals_per_day=4,
    diet_intensity=DietIntensity.FAST,
    activity_level=ActivityLevel.MODERATE,
    stress_level=StressLevel.LOW,
    sleep_quality=SleepQuality.GOOD,
)
