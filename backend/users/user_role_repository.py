from uuid import UUID

from sqlalchemy.future import select
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.models.user_role import UserRole
from backend.users.enums.role import Role


class UserRoleRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_role_by_id(self, role_id: UUID) -> UserRole | None:
        return await self.db.get(UserRole, role_id)

    async def get_role_id_by_role_name(self, role: Role) -> UserRole | None:
        query = select(UserRole).where(UserRole.name == role.value)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()
