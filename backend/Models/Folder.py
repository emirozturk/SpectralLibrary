from typing import Optional, List

from Models.SpectFile import SpectFile

class Folder:
    def __init__(
        self,
        folder_name: str,
        files: List[SpectFile],
        folder_id: Optional[int] = None,
    ):
        self.folder_id = folder_id
        self.folder_name = folder_name
        self.files = files

    def to_dict(self):
        return {
            "folder_id": self.folder_id,
            "folder_name": self.folder_name,
            "files": [file.to_dict() for file in self.files],
        }
        
    @classmethod
    def from_dict(cls, data):
        return cls(
            folder_id=data.get("folder_id"),
            folder_name=data["folder_name"],
            files=[SpectFile.from_dict(file) for file in data["files"]],
        )