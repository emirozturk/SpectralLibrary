from typing import Optional, List

class Category:
    def __init__(
        self,
        category_name_tr: str,
        category_name_en: str,
        sub_categories: Optional[List["Category"]] = None,
        category_id: Optional[int] = None,
    ):
        self.category_id = category_id
        self.category_name_tr = category_name_tr
        self.category_name_en = category_name_en
        self.sub_categories = sub_categories or []

    def to_dict(self):
        return {
            "category_id": self.category_id,
            "category_name_tr": self.category_name_tr,
            "category_name_en": self.category_name_en,
            "sub_categories": [category.to_dict() for category in self.sub_categories],
        }