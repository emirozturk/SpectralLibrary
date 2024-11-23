from typing import Optional, List

from Models.Folder import Folder


class User:
    class UserType:
        ADMIN = "admin"
        MODERATOR = "moderator"
        USER = "user"

    def __init__(
        self,
        email: str,
        password: str,
        type_: str,
        is_confirmed: bool,
        company: str,
        user_id: Optional[int] = None,
        token: Optional[str] = None,
        folders: Optional[List[Folder]] = None,
    ):
        self.user_id = user_id
        self.email = email
        self.password = password
        self.type = type_
        self.is_confirmed = is_confirmed
        self.company = company
        self.token = token
        self.folders = folders or []

    def to_dict(self):
        return {
            "user_id": self.user_id,
            "email": self.email,
            "password": self.password,
            "type": self.type,
            "is_confirmed": self.is_confirmed,
            "company": self.company,
            "token": self.token,
            "folders": [folder.to_dict() for folder in self.folders],
        }
    
    @classmethod
    def from_dict(cls, data):
        return cls(
            user_id=data.get("user_id"),
            email=data["email"],
            password=data["password"],
            type_=data["type"],
            is_confirmed=data["is_confirmed"],
            company=data["company"],
            token=data.get("token"),
            folders=[Folder.from_dict(folder) for folder in data.get("folders", [])],
        )