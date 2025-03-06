## Auth controller 
- `[POST] v1/auth/register` register new user
- `[POST] v1/auth/login` login user
- `[POST] v1/auth/logout` logout user
- `[GET] v1/auth/user` get current logged user
- `[POST] v1/auth/forgot-password` – Send email with reset password link
  
## Users controller
- `[GET] v1/users/{userId}}` get detalis about user by _userId_ 
- `[PUT] v1/users/{userId}}` update user data by _userId_ 
- `[DELETE] v1/users/{userId}` – Delete user account
- `[POST] v1/users/{userId}/change-password` – Change user password

## Diets controller
- `[GET] v1/diets/genarate/{userId}` generate diet to user by _userId_ 
- `[GET] v1/diets/{dietId}` get diet details by _dietId_ 
- `[PUT] v1/diets/{dietId}` update diet details by _dietId_ 
- `[DELETE] v1/diets/{dietId}` delete diet by _dietId_ 