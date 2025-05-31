from fastapi.params import Depends
from sqlalchemy import select
from sqlmodel.ext.asyncio.session import AsyncSession
from backend.models import UserDetails, Gender, DietType, ActivityLevel, DietIntensity, SleepQuality
from .schemas import UserDetailsCreate, UserDetailsUpdate
from backend.core.database import get_db


class UserDetailsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def add_user_details(
            self, user_details_data: UserDetailsCreate
    ) -> UserDetails:
        # Convert enum values to model instances
        db_gender = await self.db.get(Gender, user_details_data.gender.value)
        db_diet_type = await self.db.get(DietType, user_details_data.diet_type.value)
        db_activity_level = await self.db.get(ActivityLevel, user_details_data.activity_level.value)
        db_diet_intensity = await self.db.get(DietIntensity, user_details_data.diet_intensity.value)
        db_sleep_quality = await self.db.get(SleepQuality, user_details_data.sleep_quality.value)
        # ... do the same for other enum fields

        # Create the UserDetails instance with the actual model instances
        user_details_dict = user_details_data.model_dump(exclude={"allergies", "gender", "diet_type"})
        user_details = UserDetails(
            **user_details_dict,
            gender=db_gender,
            gender_id=db_gender.id,
            diet_type=db_diet_type,
            diet_type_id=db_diet_type.id,
            # ... other fields
        )

        # Handle allergies if needed
        if user_details_data.allergies:
            allergies = await self.db.execute(
                select(Allergies).where(Allergies.id.in_(user_details_data.allergies))
            )
            user_details.allergies = allergies.scalars().all()

        self.db.add(user_details)
        await self.db.commit()
        await self.db.refresh(user_details)
        return user_details

    async def get_user_details_by_id(self, user_details_id: int) -> UserDetails | None:
        return await self.db.get(UserDetails, user_details_id)

    async def get_user_details_by_user_id(self, user_id: int) -> UserDetails:
        query = select(UserDetails).where(UserDetails.user_id == user_id)
        result = await self.db.exec(query)
        return result.first()

    async def update_user_details(
        self, user_details_id: int, user_details_data: UserDetailsUpdate
    ) -> UserDetails | None:
        user = await self.get_user_details_by_id(user_details_id)
        if user:
            user_details_request = UserDetails(
                id=user_details_id, **user_details_data.model_dump(exclude_unset=True)
            )
            updated_user_details = await self.db.merge(user_details_request)
            await self.db.commit()
            await self.db.refresh(updated_user_details)
            return updated_user_details
        return None


async def get_user_details_repository(
    db: AsyncSession = Depends(get_db),
) -> UserDetailsRepository:
    return UserDetailsRepository(db)
