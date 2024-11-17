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
}
