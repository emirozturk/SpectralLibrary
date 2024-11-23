from typing import Optional


class Response:
    def __init__(self, is_success: bool, body=None, message: Optional[str] = None):
        self.is_success = is_success
        self.body = body
        self.message = message

    @classmethod
    def from_dict(cls, map: dict):
        return cls(
            is_success=map.get("isSuccess"),
            body=map.get("body"),
            message=map.get("message"),
        )

    @classmethod
    def success(cls, body):
        return cls(is_success=True, body=body, message=None)

    @classmethod
    def fail(cls, message: str):
        return cls(is_success=False, body=None, message=message)

    def to_dict(self):
        return {
            "isSuccess": self.is_success,
            "body": self.body,
            "message": self.message,
        }