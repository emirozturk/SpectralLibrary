from typing import Optional, List

from Models.Data import Data

class SpectFile:
    def __init__(
        self,
        filename: str,
        category: str,
        is_public: bool,
        data_points: List[Data],
        file_id: Optional[int] = None,
        description: Optional[str] = None,
        shared_with: Optional[List[str]] = None,
    ):
        self.file_id = file_id
        self.filename = filename
        self.category = category
        self.description = description
        self.is_public = is_public
        self.data_points = data_points
        self.shared_with = shared_with or []

    def to_map(self):
        return {
            "file_id": self.file_id,
            "filename": self.filename,
            "category": self.category,
            "description": self.description,
            "is_public": self.is_public,
            "data_points": [data.to_dict() for data in self.data_points],
            "shared_with": self.shared_with,
        }
    @classmethod
    def from_map(cls, data):
        return cls(
            file_id=data.get("file_id"),
            filename=data["filename"],
            category=data["category"],
            description=data.get("description"),
            is_public=data["is_public"],
            data_points=[Data.from_dict(dp) for dp in data["data_points"]],
            shared_with=data.get("shared_with", []),
        )
