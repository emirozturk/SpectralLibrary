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

    def to_map(self):
        return {
            "userId": self.user_id,
            "email": self.email,
            "password": self.password,
            "type": self.type,
            "isConfirmed": self.is_confirmed,
            "company": self.company,
            "token": self.token,
            "folders": [folder.to_map() for folder in self.folders],
        }
    
    @classmethod
    def from_map(cls, data):
        return cls(
            user_id=data.get("userId"),
            email=data["email"],
            password=data["password"],
            type_=data["type"],
            is_confirmed=data["isConfirmed"],
            company=data["company"],
            token=data.get("token"),
            # Use 'or []' to default to an empty list if 'folders' is None or not present
            folders=[Folder.from_map(folder) for folder in data.get("folders") or []],
        )