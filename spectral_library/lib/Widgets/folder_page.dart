import 'package:flutter/material.dart';
import 'package:spectral_library/Models/user.dart';

class FolderPage extends StatefulWidget {
  User user;
  FolderPage(this.user, {super.key});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  var folders = ["Folder1", "Folder2"];

  void rename() {}

  void delete() {}

  void createFolder() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: folders.length, // Specify itemCount
            itemBuilder: (context, index) => ListTile(
              title: Text(folders[index]),
              trailing: Row(
                mainAxisSize:
                    MainAxisSize.min, // Ensures Row takes minimal width
                children: [
                  ElevatedButton(
                    onPressed: rename,
                    child: Icon(Icons.drive_file_rename_outline),
                  ),
                  ElevatedButton(
                    onPressed: delete,
                    child: Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: createFolder,
          child: Text("Klasör Oluştur"),
        ),
      ],
    );
  }
}
