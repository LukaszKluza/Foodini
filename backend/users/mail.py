import logging
from typing import List

from fastapi import HTTPException, status
from fastapi_mail import FastMail, MessageSchema, MessageType
from fastapi_mail.errors import ConnectionErrors
from pydantic import EmailStr

logger = logging.getLogger(__name__)


class MailService:
    def __init__(self, mail: FastMail):
        self.mail = mail

    async def build_message(
        self,
        recipients: List[EmailStr],
        subject: str,
        body: str,
        subtype: MessageType = MessageType.plain,
    ) -> MessageSchema:
        return MessageSchema(
            recipients=recipients,
            subject=subject,
            body=body,
            subtype=subtype,
        )

    async def send_message(self, message: MessageSchema) -> None:
        try:
            await self.mail.send_message(message)
        except ConnectionErrors as e:
            logger.error(f"Mail sending failed: {e}")
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Email service temporarily unavailable",
            )
