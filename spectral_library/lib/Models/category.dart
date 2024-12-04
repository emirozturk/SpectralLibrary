class Category {
  int? categoryId;
  String categoryNameTr;
  String categoryNameEn;
  List<Category>? subCategories;
  Category(
      {this.categoryId,
      required this.categoryNameTr,
      required this.categoryNameEn,
      this.subCategories});
  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryNameTr': categoryNameTr,
      'categoryNameEn': categoryNameEn,
      'subCategories': subCategories?.map((sub) => sub.toMap()).toList(),
    };
  }

  /// Creates a Category object from a Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      categoryId: map['categoryId'] as int?,
      categoryNameTr: map['categoryNameTr'] as String,
      categoryNameEn: map['categoryNameEn'] as String,
      subCategories: (map['subCategories'] as List<dynamic>?)
          ?.map((subMap) => Category.fromMap(subMap as Map<String, dynamic>))
          .toList(),
    );
  }
}
