import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:spectral_library/Models/user.dart';

class UploadFilePage extends StatefulWidget {
  User user;

  UploadFilePage(this.user, {super.key});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  var filenames;

  var categories = [""];

  var subcategories = [""];

  var folders = [""];

  var selectedCategory;

  var selectedSubCategory;

  var selectedFolder;

  void selectFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      filenames = files.map((x) => basename(x.path)).toList();
    } else {
      // User canceled the picker
    }
  }

  void uploadFiles() async {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: selectFiles,
          child: const Row(
            children: [
              Icon(Icons.file_copy),
              Text("Dosya Seç"),
            ],
          ),
        ),
        filenames != null ? Text("Dosya Seçildi") : Text("Dosya Seçilmedi"),
        DropdownMenu<String>(
          initialSelection: categories.first,
          onSelected: (String? value) {
            setState(() {
              selectedCategory = value!;
            });
          },
          dropdownMenuEntries:
              categories.map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry<String>(value: value, label: value);
          }).toList(),
        ),
        DropdownMenu<String>(
          initialSelection: categories.first,
          onSelected: (String? value) {
            setState(() {
              selectedSubCategory = value!;
            });
          },
          dropdownMenuEntries:
              subcategories.map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry<String>(value: value, label: value);
          }).toList(),
        ),
        DropdownMenu<String>(
          initialSelection: categories.first,
          onSelected: (String? value) {
            setState(() {
              selectedFolder = value!;
            });
          },
          dropdownMenuEntries:
              folders.map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry<String>(value: value, label: value);
          }).toList(),
        ),
        ElevatedButton(
          onPressed: uploadFiles,
          child: const Row(
            children: [
              Icon(Icons.upload_file),
              Text("Yükle"),
            ],
          ),
        ),
      ],
    );
  }
}
