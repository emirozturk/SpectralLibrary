import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/user_controller.dart';
import 'package:spectral_library/Models/folder.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/util.dart';
import 'package:easy_localization/easy_localization.dart';

class FolderPage extends StatefulWidget {
  final User user;
  const FolderPage(this.user, {super.key});

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
    final response = await UserController.updateUser(widget.user, widget.user);
    if (response.isSuccess) {
      Util.showInfoDialog(context: context, content: response.message!);
    } else {
      Util.showErrorDialog(context: context, content: response.message!);
    }
    setState(() {});
  }

  Future<void> rename(int index) async {
    final inputText = await showInputDialog(context);
    if (inputText != null) {
      widget.user.folders![index].folderName = inputText;
      updateUser();
    }
  }

  void delete(int index) {
    Util.showCustomDialog(
      context: context,
      title: "folder_page.are_you_sure".tr(), // "Are you sure?"
      content: "folder_page.delete_folder".tr(), // "Delete Folder?"
      function: () {
        widget.user.folders!.removeAt(index);
        updateUser();
      },
    );
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
      builder: (BuildContext ctx) {
        return AlertDialog(
          title:
              Text("folder_page.enter_folder_name".tr()), // "Enter Folder Name"
          content: TextField(
            onChanged: (value) {
              inputText = value;
            },
            decoration: InputDecoration(
              hintText:
                  "folder_page.enter_folder_name_hint".tr(), // "Folder Name"
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(null);
              },
              child: Text("folder_page.cancel".tr()), // "Cancel"
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(inputText);
              },
              child: Text("folder_page.submit".tr()), // "Submit"
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
              itemCount: folders?.length ?? 0,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  title: Text(
                    folders![index].folderName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => delete(index),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: createFolder,
            icon: const Icon(Icons.create_new_folder),
            label: Text("folder_page.create_folder".tr()), // "Klasör Oluştur"
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
