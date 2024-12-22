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
        # Ensure sub_categories is always a list
        self.sub_categories = sub_categories if sub_categories is not None else []

    # Converts the object into a JSON-serializable dictionary
    def to_map(self):
        return {
            "categoryId": self.category_id,
            "categoryNameTr": self.category_name_tr,
            "categoryNameEn": self.category_name_en,
            # If sub_categories is None, send an empty list []
            "subCategories": [category.to_map() for category in self.sub_categories] if self.sub_categories else []
        }

    # Constructs the object from a dictionary
    @classmethod
    def from_map(cls, data):
        # Default subCategories to an empty list if it is None
        sub_categories = data.get("subCategories", [])
        if sub_categories is None:  # Safeguard against explicitly null values
            sub_categories = []

        # Map subcategories recursively
        return cls(
            category_id=data.get("categoryId"),  # Handles None for category_id
            category_name_tr=data["categoryNameTr"],  # Required
            category_name_en=data["categoryNameEn"],  # Required
            sub_categories=[Category.from_map(dp) for dp in sub_categories],  # Recursive mapping
        )
