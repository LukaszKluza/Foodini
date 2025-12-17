from backend.users.dependencies import require_roles
from backend.users.enums.role import Role

user_or_admin = require_roles(Role.USER, Role.ADMIN)
admin_only = require_roles(Role.ADMIN)
