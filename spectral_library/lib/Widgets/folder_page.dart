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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: folders!.length, // Specify itemCount
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  title: Text(
                    folders![index].folderName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => rename(index),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Icon(Icons.drive_file_rename_outline),
                      ),
                      const SizedBox(width: 8), // Add spacing between buttons
                      ElevatedButton(
                        onPressed: () => delete(index),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: Colors.red, // Red for delete button
                        ),
                        child: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16), // Space between list and button
          ElevatedButton.icon(
            onPressed: createFolder,
            icon: const Icon(Icons.create_new_folder),
            label: const Text("Klasör Oluştur"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
