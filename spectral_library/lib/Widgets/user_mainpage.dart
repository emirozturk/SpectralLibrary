import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/category_controller.dart';
import 'package:spectral_library/Models/category.dart';
import 'package:spectral_library/Models/folder.dart';
import 'package:spectral_library/Models/spect_file.dart';
import 'package:spectral_library/Models/user.dart';

class UserMainpage extends StatefulWidget {
  final User user;
  const UserMainpage(this.user, {super.key});

  @override
  _UserMainpageState createState() => _UserMainpageState();
}

class _UserMainpageState extends State<UserMainpage> {
  List<Category> categories = [];
  List<Category> subcategories = [];
  List<Folder> folders = [];
  List<SpectFile> files = [];
  List<String> filteredFiles = [];
  List<String> selectedFiles = [];

  String? selectedCategory;
  String? selectedSubcategory;
  String? selectedFolder;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    var categoryResponse = await CategoryController.getCategories(widget.user);
    if (categoryResponse.isSuccess) {
      categories = (categoryResponse.body as List<dynamic>)
          .map((x) => Category.fromMap(x))
          .toList();
    }
    folders = widget.user.folders!;
    files = widget.user.folders!
        .map((x) => x.files)
        .expand((list) => list!)
        .toList();
    filteredFiles = files.map((x) => x.filename).toList();
    setState(() {});
  }

  Future<void> _fetchFiles() async {
    setState(() {
      files = widget.user.folders!
          .where((folder) {
            // Filter folders by the selected folder name, if provided
            if (selectedFolder != null && folder.folderName != selectedFolder) {
              return false;
            }
            return true;
          })
          .expand((folder) => folder.files ?? []) // Flatten the files list
          .where((file) {
            // Filter files by category and subcategory, if provided
            if (selectedCategory != null && file.category != selectedCategory) {
              return false;
            }
            if (selectedSubcategory != null &&
                file.subcategory != selectedSubcategory) {
              return false;
            }
            return true;
          })
          .cast<SpectFile>() // Explicitly cast to List<SpectFile>
          .toList();

      // Update the filtered files for the dropdown
      filteredFiles = files.map((file) => file.filename).toList();
    });
  }

  void _onDrawPlots() {
    if (selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select files to draw plots.")),
      );
      return;
    }
    print("Selected files for plotting: $selectedFiles");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Category",
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map((category) => DropdownMenuItem(
                        value: category.categoryNameTr,
                        child: Text(category.categoryNameTr)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                  _fetchFiles();
                },
              ),
            ),
            // Subcategory Dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Subcategory",
                  border: OutlineInputBorder(),
                ),
                items: subcategories
                    .map((subcategory) => DropdownMenuItem(
                        value: subcategory.categoryNameTr,
                        child: Text(subcategory.categoryNameTr)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubcategory = value;
                  });
                  _fetchFiles();
                },
              ),
            ),
            // Folder Dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Folder",
                  border: OutlineInputBorder(),
                ),
                items: folders
                    .map((folder) => DropdownMenuItem(
                        value: folder.folderName,
                        child: Text(folder.folderName)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFolder = value;
                  });
                  _fetchFiles();
                },
              ),
            ),
            // File List
            Expanded(
              child: files.isEmpty
                  ? const Center(child: Text("No files to display."))
                  : ListView.builder(
                      itemCount: filteredFiles.length,
                      itemBuilder: (context, index) {
                        final filename = filteredFiles[index];
                        return CheckboxListTile(
                          title: Text(filename),
                          value: selectedFiles.contains(filename),
                          onChanged: (isSelected) {
                            setState(() {
                              if (isSelected == true) {
                                selectedFiles.add(filename);
                              } else {
                                selectedFiles.remove(filename);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            // Draw Plots Button
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ElevatedButton(
                onPressed: _onDrawPlots,
                child: const Text("Draw Plots"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
