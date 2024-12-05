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

    def to_map(self):
        return {
            "categoryId": self.category_id,
            "categoryNameTr": self.category_name_tr,
            "categoryNameEn": self.category_name_en,
            "subCategories": [category.to_map() for category in self.sub_categories],
        }
    @classmethod
    def from_map(cls, data):
        return cls(
            category_id=data.get("categoryId"),
            category_name_tr=data["categoryNameTr"],
            category_name_en=data["categoryNameEn"],
            sub_categories=[Category.from_map(dp) for dp in data.get("subCategories",[])],
        )
