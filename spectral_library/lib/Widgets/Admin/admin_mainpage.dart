import 'package:flutter/material.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Controllers/admin_controller.dart';
import 'package:easy_localization/easy_localization.dart';

class AdminMainpage extends StatefulWidget {
  final User user;
  const AdminMainpage(this.user, {super.key});

  @override
  _AdminMainpageState createState() => _AdminMainpageState();
}

class _AdminMainpageState extends State<AdminMainpage> {
  int userCount = 0;
  int fileCount = 0;
  int folderCount = 0;

  // Instead of Map<String, double> use a list of CategoryRatio
  List<CategoryRatio> fileCategoryRatios = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    setState(() => isLoading = true);

    final userCountResponse = await AdminController.getUserCount(widget.user);
    final fileCountResponse = await AdminController.getFileCount(widget.user);
    final folderCountResponse =
        await AdminController.getFolderCount(widget.user);
    final fileCategoryRatiosResponse =
        await AdminController.getFileCategoryRatios(widget.user);

    if (userCountResponse.isSuccess) {
      userCount = userCountResponse.body as int;
    }
    if (fileCountResponse.isSuccess) {
      fileCount = fileCountResponse.body as int;
    }
    if (folderCountResponse.isSuccess) {
      folderCount = folderCountResponse.body as int;
    }

    if (fileCategoryRatiosResponse.isSuccess) {
      final rawMap =
          fileCategoryRatiosResponse.body as Map<String, dynamic>? ?? {};

      final rawList = rawMap["data"] as List<dynamic>? ?? [];

      fileCategoryRatios = rawList
          .map((item) => CategoryRatio.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    setState(() => isLoading = false);
  }

  /// Build a list of categories with localized names
  Widget _buildCategoryRatioList() {
    final locale = context.locale.languageCode; // e.g., "tr" or "en"

    return Column(
      children: fileCategoryRatios.map((catRatio) {
        // If locale is "tr", display categoryNameTr; else categoryNameEn
        final categoryName = (locale == 'tr')
            ? catRatio.categoryNameTr
            : catRatio.categoryNameEn;

        return ListTile(
          title: Text(categoryName),
          trailing: Text("${(catRatio.ratio * 100).toStringAsFixed(2)}%"),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Users
                  ListTile(
                    title: Text("admin_mainpage.registered_users".tr()),
                    trailing: Text(userCount.toString()),
                  ),
                  // Files
                  ListTile(
                    title: Text("admin_mainpage.total_files".tr()),
                    trailing: Text(fileCount.toString()),
                  ),
                  // Folders
                  ListTile(
                    title: Text("admin_mainpage.total_folders".tr()),
                    trailing: Text(folderCount.toString()),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "admin_mainpage.file_category_ratios".tr(),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildCategoryRatioList(),
                ],
              ),
            ),
    );
  }
}

class CategoryRatio {
  final String categoryNameTr;
  final String categoryNameEn;
  final double ratio;

  CategoryRatio({
    required this.categoryNameTr,
    required this.categoryNameEn,
    required this.ratio,
  });

  factory CategoryRatio.fromMap(Map<String, dynamic> map) {
    return CategoryRatio(
      categoryNameTr: map["categoryNameTr"] as String,
      categoryNameEn: map["categoryNameEn"] as String,
      ratio: (map["ratio"] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "categoryNameTr": categoryNameTr,
      "categoryNameEn": categoryNameEn,
      "ratio": ratio,
    };
  }
}
