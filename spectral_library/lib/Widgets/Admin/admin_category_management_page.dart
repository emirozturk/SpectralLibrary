import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/category_controller.dart';
import 'package:spectral_library/Models/category.dart';
import 'package:spectral_library/Models/user.dart';

class AdminCategoryManagementPage extends StatefulWidget {
  final User user;

  AdminCategoryManagementPage(this.user, {super.key});

  @override
  _AdminCategoryManagementPageState createState() =>
      _AdminCategoryManagementPageState();
}

class _AdminCategoryManagementPageState
    extends State<AdminCategoryManagementPage> {
  List<Category> categories = [];
  TextEditingController searchController = TextEditingController();
  List<Category> filteredCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => isLoading = true);
    var response = await CategoryController.getCategories(widget.user);
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
          title: Text(category == null ? "Add Category" : "Edit Category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameTrController,
                decoration: InputDecoration(labelText: "Category Name (TR)"),
              ),
              TextField(
                controller: nameEnController,
                decoration: InputDecoration(labelText: "Category Name (EN)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (category == null) {
                  var newCategory = Category(
                    categoryNameTr: nameTrController.text,
                    categoryNameEn: nameEnController.text,
                  );
                  var response = await CategoryController.addCategory(
                      widget.user, newCategory);
                  if (response.isSuccess) {
                    setState(() => _fetchCategories());
                  }
                } else {
                  category.categoryNameTr = nameTrController.text;
                  category.categoryNameEn = nameEnController.text;
                  var response = await CategoryController.updateCategory(
                      widget.user, category);
                  if (response.isSuccess) {
                    setState(() => _fetchCategories());
                  }
                }
              },
              child: const Text("Save"),
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
        title: const Text("Delete Category"),
        content: Text(
            "Are you sure you want to delete the category '${category.categoryNameTr}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              var response = await CategoryController.deleteCategory(
                  widget.user, category);
              if (response.isSuccess) {
                setState(() => _fetchCategories());
              }
            },
            child: const Text("Delete"),
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
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Categories",
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
                      children: filteredCategories
                          .map((category) => _buildCategoryItem(category))
                          .toList(),
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
