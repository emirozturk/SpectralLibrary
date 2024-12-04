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

    def to_map(self):
        return {
            "folderId": self.folder_id,
            "folderName": self.folder_name,
            "files": [file.to_map() for file in self.files],
        }
        
    @classmethod
    def from_map(cls, data):
        return cls(
            folder_id=data.get("folderId"),
            folder_name=data["folderName"],
            files=[SpectFile.from_map(file) for file in (data["files"] or [])],
        )