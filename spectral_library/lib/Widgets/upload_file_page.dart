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

class UploadFilePage extends StatefulWidget {
  User user;

  UploadFilePage(this.user, {super.key});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  bool firstLoad = true;

  var filenames;

  List<Category> categories = [];

  List<Category> subcategories = [];

  List<Folder> folders = [];

  var selectedCategory;

  var selectedSubCategory;

  var selectedFolder;

  List<Uint8List> selectedFiles = [];
  List<TextEditingController> desiredFilenamesControllers = [];
  List<TextEditingController> descriptionControllers = [];

  Future<void> selectFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        // Use bytes for web compatibility
        selectedFiles = result.files.map((file) => file.bytes!).toList();
        filenames = result.files.map((file) => file.name).toList();
      });
    } else {
      // User canceled the picker
    }
  }

  Future<SpectFile> parseFileToSpectFiles(
      Uint8List fileBytes, String filename, String description) async {
    // Convert bytes to a string
    String fileContent = String.fromCharCodes(fileBytes);

    List<String> lines = fileContent.split('\n');

    List<Data> datapoints =
        lines.where((line) => line.trim().isNotEmpty).map((line) {
      List<String> values = line.split(",");
      return Data(
        x: double.parse(values[0]),
        y: double.parse(values[1]),
      );
    }).toList();

    // Create a single SpectFile for this file
    SpectFile spectFile = SpectFile(
      filename: filename,
      category: selectedFolder!,
      isPublic: false,
      dataPoints: datapoints,
      description: description,
    );

    return spectFile;
  }

  Future<void> uploadFiles(context) async {
    if (selectedFolder == null) {
      Util.showErrorSnackBar(context, "Please select a folder");
      return;
    }

    Folder? folder = widget.user.folders
        ?.firstWhere((folder) => folder.folderName == selectedFolder);

    for (int i = 0; i < selectedFiles.length; i++) {
      String filename = desiredFilenamesControllers[i].text;
      String description = descriptionControllers[i].text;

      if (filename.isEmpty || description.isEmpty) {
        Util.showErrorSnackBar(
            context, "Please provide filenames and descriptions for all files");
        return;
      }

      SpectFile spectFile =
          await parseFileToSpectFiles(selectedFiles[i], filename, description);

      folder!.files!.add(spectFile);
    }

    await UserController.updateUser(widget.user);

    // Clear all fields after upload
    clearForm();
    Util.showErrorSnackBar(context, "Files uploaded successfully!");
  }

  void fetchCategories(context) async {
    var response = await CategoryController.getCategories(widget.user);
    if (response.isSuccess) {
      setState(() {
        categories = (response.body as List<dynamic>)
            .map((x) => Category.fromMap(x as Map<String, dynamic>))
            .toList();
      });
    } else {
      Util.showErrorSnackBar(context, response.message);
    }
  }

  void fillSubCategories(name) {
    subcategories =
        categories.where((x) => x.categoryNameTr == name).first.subCategories ??
            [];
  }

  void fillFolders() {
    folders = widget.user.folders ?? [];
  }

  void fetch(context) {
    fetchCategories(context);
    fillFolders();
  }

  void clearForm() {
    setState(() {
      selectedCategory = null;
      selectedSubCategory = null;
      selectedFolder = null;
      filenames = null;
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
            ElevatedButton.icon(
              onPressed: () async {
                await selectFiles();
                setState(() {
                  for (var file in selectedFiles) {
                    desiredFilenamesControllers.add(TextEditingController());
                    descriptionControllers.add(TextEditingController());
                  }
                });
              },
              icon: const Icon(Icons.file_copy),
              label: const Text("Select Files"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            filenames != null
                ? const Text("Files Selected",
                    style: TextStyle(fontWeight: FontWeight.bold))
                : const Text("No Files Selected",
                    style: TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
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
                        Text(
                          "Original Filename: ${filenames[index]}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: desiredFilenamesControllers[index],
                          decoration: const InputDecoration(
                            labelText: "Desired Filename",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descriptionControllers[index],
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: "Description",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
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
            DropdownSection(
              label: "Category",
              items: categories.map((x) => x.categoryNameTr).toList(),
              selectedItem: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  fillSubCategories(value);
                });
              },
            ),
            DropdownSection(
              label: "Subcategory",
              items: subcategories.map((x) => x.categoryNameTr).toList(),
              selectedItem: selectedSubCategory,
              onChanged: (value) {
                setState(() {
                  selectedSubCategory = value;
                });
              },
            ),
            DropdownSection(
              label: "Folder",
              items: folders.map((x) => x.folderName).toList(),
              selectedItem: selectedFolder,
              onChanged: (value) {
                setState(() {
                  selectedFolder = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await uploadFiles(context);
              },
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }
}
