import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/category_controller.dart';
import 'package:spectral_library/Controllers/user_controller.dart';
import 'package:spectral_library/Models/category.dart';
import 'package:spectral_library/Models/data.dart';
import 'package:spectral_library/Models/folder.dart';
import 'package:spectral_library/Models/spect_file.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/util.dart';
import 'package:easy_localization/easy_localization.dart';

class UploadFilePage extends StatefulWidget {
  final User user;
  const UploadFilePage(this.user, {super.key});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  bool firstLoad = true;

  List<Uint8List> selectedFiles = [];
  List<String> filenames = [];
  List<TextEditingController> desiredFilenamesControllers = [];
  List<TextEditingController> descriptionControllers = [];

  List<Category> categories = [];
  List<Category> subcategories = [];
  List<Folder> folders = [];

  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedFolder;

  final _formKey = GlobalKey<FormState>();

  Future<void> selectFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      bool hasLargeFile = false;
      for (var file in result.files) {
        if (file.size > 50 * 1024 * 1024) {
          // Example: 50 MB limit
          hasLargeFile = true;
          break;
        }
      }
      if (hasLargeFile) {
        Util.showErrorDialog(
          context: context,
          content: "upload_file_page.file_size_exceeded".tr(),
        );
        return;
      }
      setState(() {
        selectedFiles = result.files.map((file) => file.bytes!).toList();
        filenames = result.files.map((file) => file.name).toList();
        desiredFilenamesControllers =
            List.generate(selectedFiles.length, (_) => TextEditingController());
        descriptionControllers =
            List.generate(selectedFiles.length, (_) => TextEditingController());
      });
    }
  }

  Future<SpectFile> parseFileToSpectFiles(
    Uint8List fileBytes,
    String filename,
    String description,
  ) async {
    final fileContent = String.fromCharCodes(fileBytes);
    final lines = fileContent.split('\n');

    final datapoints =
        lines.where((line) => line.trim().isNotEmpty).map((line) {
      final values = line.split(",");
      if (values.length < 2) {
        throw FormatException("Invalid data format in file.");
      }
      return Data(
        x: double.parse(values[0]),
        y: double.parse(values[1]),
      );
    }).toList();

    final category = categories.firstWhere(
        (x) =>
            x.categoryNameTr == selectedCategory ||
            x.categoryNameEn == selectedCategory,
        orElse: () => Category(categoryNameTr: "", categoryNameEn: ""));

    if (category.categoryNameTr.isEmpty && category.categoryNameEn.isEmpty) {
      throw Exception("Selected category not found.");
    }

    final spectFile = SpectFile(
      filename: filename,
      category: category,
      isPublic: false,
      dataPoints: datapoints,
      description: description,
    );
    return spectFile;
  }

  Future<void> uploadFiles(BuildContext context) async {
    // Validation
    if (selectedFiles.isEmpty) {
      Util.showErrorDialog(
        context: context,
        content: "upload_file_page.please_select_files".tr(),
      );
      return;
    }

    if (selectedCategory == null || selectedCategory!.isEmpty) {
      Util.showErrorDialog(
        context: context,
        content: "upload_file_page.please_select_category".tr(),
      );
      return;
    }

    if (selectedSubCategory == null || selectedSubCategory!.isEmpty) {
      Util.showErrorDialog(
        context: context,
        content: "upload_file_page.please_select_subcategory".tr(),
      );
      return;
    }

    if (selectedFolder == null || selectedFolder!.isEmpty) {
      Util.showErrorDialog(
        context: context,
        content: "upload_file_page.please_select_folder".tr(),
      );
      return;
    }

    // Validate each file's desired filename and description
    for (int i = 0; i < selectedFiles.length; i++) {
      final filename = desiredFilenamesControllers[i].text.trim();
      final description = descriptionControllers[i].text.trim();
      if (filename.isEmpty) {
        Util.showErrorDialog(
          context: context,
          content: "upload_file_page.please_provide_filenames".tr(),
        );
        return;
      }
      if (description.isEmpty) {
        Util.showErrorDialog(
          context: context,
          content: "upload_file_page.please_provide_descriptions".tr(),
        );
        return;
      }
    }

    // Proceed with uploading
    try {
      final folder = widget.user.folders?.firstWhere(
          (f) => f.folderName == selectedFolder,
          orElse: () => Folder(folderName: ""));

      if (folder!.folderName.isEmpty) {
        throw Exception("Selected folder not found.");
      }

      // Parse and add files
      for (int i = 0; i < selectedFiles.length; i++) {
        final filename = desiredFilenamesControllers[i].text.trim();
        final description = descriptionControllers[i].text.trim();

        final spectFile = await parseFileToSpectFiles(
            selectedFiles[i], filename, description);
        folder.files ??= [];
        folder.files!.add(spectFile);
      }

      // Update user in DB
      final response =
          await UserController.updateUser(widget.user, widget.user);

      if (response.isSuccess) {
        // Clear form
        clearForm();

        // Show success message
        Util.showInfoDialog(
          context: context,
          content: "upload_file_page.files_uploaded_successfully".tr(),
        );
      } else {
        // Show error message from response
        Util.showErrorDialog(
          context: context,
          content: response.message ?? "An error occurred.",
        );
      }
    } catch (e) {
      // Handle any unexpected errors
      Util.showErrorDialog(
        context: context,
        content: e.toString(),
      );
    }
  }

  void fetchCategories(BuildContext context) async {
    final response = await CategoryController.getCategories(widget.user);
    if (response.isSuccess) {
      setState(() {
        categories = (response.body as List<dynamic>)
            .map((x) => Category.fromMap(x as Map<String, dynamic>))
            .toList();
      });
    } else {
      Util.showErrorDialog(context: context, content: response.message!);
    }
  }

  void fillSubCategories(String name) {
    final mainCat = categories.firstWhere(
        (x) => x.categoryNameTr == name || x.categoryNameEn == name,
        orElse: () => Category(categoryNameTr: "", categoryNameEn: ""));
    subcategories = mainCat.subCategories ?? [];
  }

  void fillFolders() {
    folders = widget.user.folders ?? [];
  }

  void fetch(BuildContext context) {
    fetchCategories(context);
    fillFolders();
  }

  void clearForm() {
    setState(() {
      selectedCategory = null;
      selectedSubCategory = null;
      selectedFolder = null;
      filenames.clear();
      selectedFiles.clear();
      desiredFilenamesControllers.clear();
      descriptionControllers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (firstLoad) {
      firstLoad = false;
      fetch(context);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Files Button
            ElevatedButton.icon(
              onPressed: () async {
                await selectFiles();
              },
              icon: const Icon(Icons.file_copy),
              label: Text("upload_file_page.select_files".tr()),
            ),
            const SizedBox(height: 16),

            // Display Selected Files Status
            Text(
              filenames.isNotEmpty
                  ? "upload_file_page.files_selected".tr()
                  : "upload_file_page.no_files_selected".tr(),
              style: TextStyle(
                fontWeight:
                    filenames.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                fontStyle:
                    filenames.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),

            const SizedBox(height: 16),

            // List of chosen files
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedFiles.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Original Filename
                        Text(
                          "${"upload_file_page.original_filename".tr()}: ${filenames[index]}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        // Desired Filename
                        TextField(
                          controller: desiredFilenamesControllers[index],
                          decoration: InputDecoration(
                            labelText:
                                "upload_file_page.desired_filename".tr() + " *",
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        TextField(
                          controller: descriptionControllers[index],
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText:
                                "upload_file_page.description".tr() + " *",
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Delete File Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                filenames.removeAt(index);
                                selectedFiles.removeAt(index);
                                desiredFilenamesControllers.removeAt(index);
                                descriptionControllers.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownSection(
              label: "upload_file_page.category".tr() + " *",
              items: categories
                  .map((x) => x.categoryNameTr.isNotEmpty
                      ? x.categoryNameTr
                      : x.categoryNameEn)
                  .toList(),
              selectedItem: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  fillSubCategories(value!);
                  selectedSubCategory = null; // Reset subcategory
                });
              },
            ),

            // SubCategory Dropdown
            DropdownSection(
              label: "upload_file_page.subcategory".tr() + " *",
              items: subcategories
                  .map((x) => x.categoryNameTr.isNotEmpty
                      ? x.categoryNameTr
                      : x.categoryNameEn)
                  .toList(),
              selectedItem: selectedSubCategory,
              onChanged: (value) {
                setState(() {
                  selectedSubCategory = value;
                });
              },
            ),

            // Folder Dropdown
            DropdownSection(
              label: "upload_file_page.folder".tr() + " *",
              items: folders.map((x) => x.folderName).toList(),
              selectedItem: selectedFolder,
              onChanged: (value) {
                setState(() {
                  selectedFolder = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Upload Button
            ElevatedButton.icon(
              onPressed: () async {
                await uploadFiles(context);
              },
              icon: const Icon(Icons.upload_file),
              label: Text("upload_file_page.upload".tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class DropdownSection extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? selectedItem;
  final void Function(String?) onChanged;

  const DropdownSection({
    required this.label,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedItem,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
