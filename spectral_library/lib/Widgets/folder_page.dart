import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/user_controller.dart';
import 'package:spectral_library/Models/folder.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/util.dart';

class FolderPage extends StatefulWidget {
  User user;
  FolderPage(this.user, {super.key});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  List<Folder>? folders;

  @override
  void initState() {
    super.initState();
    folders = widget.user.folders;
  }

  void updateUser() async {
    var response = await UserController.updateUser(widget.user);
    if (response.isSuccess) {
      Util.showErrorSnackBar(context, "Success");
    } else {
      Util.showErrorSnackBar(context, response.message);
    }
    setState(() {});
  }

  void rename(index) async {
    final inputText = await showInputDialog(context);
    if (inputText != null) {
      widget.user.folders![index].folderName = inputText;
      updateUser();
    }
  }

  void delete(index) {
    Util.showCustomDialog(
        context: context,
        title: "Are you sure?",
        content: "Delete Folder?",
        function: () {
          widget.user.folders!.removeAt(index);
          updateUser();
        });
  }

  void createFolder() async {
    final inputText = await showInputDialog(context);
    if (inputText != null) {
      widget.user.folders!.add(Folder(folderName: inputText));
      updateUser();
    }
  }

  Future<String?> showInputDialog(BuildContext context) async {
    String? inputText;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Folder Name'),
          content: TextField(
            onChanged: (value) {
              inputText = value;
            },
            decoration: const InputDecoration(hintText: 'Enter Folder Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(null); // Close dialog without returning a value
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(inputText); // Return the input text
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: folders!.length, // Specify itemCount
            itemBuilder: (context, index) => ListTile(
              title: Text(folders![index].folderName),
              trailing: Row(
                mainAxisSize:
                    MainAxisSize.min, // Ensures Row takes minimal width
                children: [
                  ElevatedButton(
                    onPressed: () => rename(index),
                    child: const Icon(Icons.drive_file_rename_outline),
                  ),
                  ElevatedButton(
                    onPressed: () => delete(index),
                    child: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: createFolder,
          child: const Text("Klasör Oluştur"),
        ),
      ],
    );
  }
}
