import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/category_controller.dart';
import 'package:spectral_library/Models/category.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:easy_localization/easy_localization.dart';

class AdminCategoryManagementPage extends StatefulWidget {
  final User user;

  const AdminCategoryManagementPage(this.user, {super.key});

  @override
  _AdminCategoryManagementPageState createState() =>
      _AdminCategoryManagementPageState();
}

class _AdminCategoryManagementPageState
    extends State<AdminCategoryManagementPage> {
  List<Category> categories = [];
  final TextEditingController searchController = TextEditingController();
  List<Category> filteredCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => isLoading = true);
    final response = await CategoryController.getCategories(widget.user);
    if (response.isSuccess) {
      categories = (response.body as List<dynamic>)
          .map((x) => Category.fromMap(x))
          .toList();
      filteredCategories = List.from(categories);
    }
    setState(() => isLoading = false);
  }

  void _filterCategories(String query) {
    setState(() {
      filteredCategories = categories
          .where((category) =>
              category.categoryNameTr
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              category.categoryNameEn
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addOrEditCategory({Category? category}) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController nameTrController =
            TextEditingController(text: category?.categoryNameTr ?? "");
        final TextEditingController nameEnController =
            TextEditingController(text: category?.categoryNameEn ?? "");

        return AlertDialog(
          title: Text(
            category == null
                ? "admin_category_management.add_category".tr()
                : "admin_category_management.edit_category".tr(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameTrController,
                decoration: InputDecoration(
                  labelText: "admin_category_management.category_name_tr".tr(),
                ),
              ),
              TextField(
                controller: nameEnController,
                decoration: InputDecoration(
                  labelText: "admin_category_management.category_name_en".tr(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("admin_category_management.cancel".tr()),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (category == null) {
                  final newCategory = Category(
                    categoryNameTr: nameTrController.text,
                    categoryNameEn: nameEnController.text,
                  );
                  final response = await CategoryController.addCategory(
                      widget.user, newCategory);
                  if (response.isSuccess) {
                    _fetchCategories();
                    setState(() {});
                  }
                } else {
                  var oldCatNameTr = category.categoryNameTr;
                  var oldCatNameEn = category.categoryNameEn;
                  category.categoryNameTr = nameTrController.text;
                  category.categoryNameEn = nameEnController.text;
                  final response = await CategoryController.updateCategory(
                      widget.user, category, oldCatNameTr, oldCatNameEn);
                  if (response.isSuccess) {
                    _fetchCategories();
                    setState(() {});
                  }
                }
              },
              child: Text("admin_category_management.save".tr()),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("admin_category_management.delete_category".tr()),
        content: Text(
          "admin_category_management.delete_category_question".tr(
            namedArgs: {"categoryName": category.categoryNameTr},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("admin_category_management.cancel".tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final response = await CategoryController.deleteCategory(
                  widget.user, category);
              if (response.isSuccess) {
                _fetchCategories();
                setState(() {});
              }
            },
            child: Text("admin_category_management.delete_category".tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    return ListTile(
      title: Text(category.categoryNameTr),
      subtitle: Text(category.categoryNameEn),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _addOrEditCategory(category: category),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteCategory(category),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // "Search Categories"
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "admin_category_management.search_categories".tr(),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: _filterCategories,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children:
                          filteredCategories.map(_buildCategoryItem).toList(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditCategory(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
