import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/category_controller.dart';
import 'package:spectral_library/Controllers/user_controller.dart';
import 'package:spectral_library/Models/category.dart';
import 'package:spectral_library/Models/folder.dart';
import 'package:spectral_library/Models/spect_file.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Widgets/draw_plot_page.dart';

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
  List<SpectFile> sharedFiles = [];
  List<SpectFile> publicFiles = [];
  List<User> allUsers = [];
  List<SpectFile> selectedFiles = [];
  List<SpectFile> selectedSharedFiles = [];
  List<SpectFile> selectedPublicFiles = [];

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

    var sharedFilesResponse = await UserController.getSharedFiles(widget.user);
    if (sharedFilesResponse.isSuccess) {
      sharedFiles = (sharedFilesResponse.body as List<dynamic>)
          .map((x) => SpectFile.fromMap(x))
          .toList();
    }

    var publicFilesResponse = await UserController.getPublicFiles(widget.user);
    if (publicFilesResponse.isSuccess) {
      publicFiles = (publicFilesResponse.body as List<dynamic>)
          .map((x) => SpectFile.fromMap(x))
          .toList();
    }

    var usersResponse = await UserController.getUsers(widget.user);
    if (usersResponse.isSuccess) {
      allUsers = (usersResponse.body as List<dynamic>)
          .map((x) => User.fromMap(x))
          .toList();
    }

    setState(() {});
  }

  Future<void> _deleteFile(SpectFile file) async {
    setState(() {
      for (var folder in widget.user.folders!) {
        folder.files?.removeWhere((f) => f.filename == file.filename);
      }
      files.remove(file);
    });
    await UserController.updateUser(widget.user);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("File deleted successfully.")),
    );
  }

  Future<void> _togglePublic(SpectFile file) async {
    setState(() {
      file.isPublic = !file.isPublic;
    });
    await UserController.updateUser(widget.user);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "File '${file.filename}' is now ${file.isPublic ? "public" : "private"}.",
        ),
      ),
    );
  }

  Future<void> _shareFile(SpectFile file) async {
    Set<String> selectedUserEmails = file.sharedWith?.toSet() ?? {};
    TextEditingController searchController = TextEditingController();
    List<User> filteredUsers = allUsers;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Share File: ${file.filename}"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Field
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: "Search Users",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredUsers = allUsers.where((user) {
                            return user.email
                                .toLowerCase()
                                .contains(value.toLowerCase());
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    // User List
                    Flexible(
                      child: filteredUsers.isEmpty
                          ? const Center(child: Text("No users found."))
                          : ListView(
                              shrinkWrap: true,
                              children: filteredUsers.map((user) {
                                bool isSelected =
                                    selectedUserEmails.contains(user.email);
                                return CheckboxListTile(
                                  title: Text(user.email),
                                  value: isSelected,
                                  onChanged: (selected) {
                                    setState(() {
                                      if (selected == true) {
                                        selectedUserEmails.add(user.email);
                                      } else {
                                        selectedUserEmails.remove(user.email);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                file.sharedWith = selectedUserEmails.toList();
                await UserController.updateUser(widget.user);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text("File '${file.filename}' shared successfully."),
                  ),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _onDrawPlots(List<SpectFile> selectedFiles) {
    if (selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No files selected for plotting.")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrawPlotPage(selectedFiles: selectedFiles),
      ),
    );
  }

  Widget _buildUserFilesSection() {
    return ExpansionTile(
      title: const Text("Your Files"),
      children: [
        ...files.map((file) {
          return CheckboxListTile(
            title: Text(file.filename),
            subtitle:
                Text("Category: ${file.category}, Public: ${file.isPublic}"),
            value: selectedFiles.contains(file),
            onChanged: (isSelected) {
              setState(() {
                if (isSelected == true) {
                  selectedFiles.add(file);
                } else {
                  selectedFiles.remove(file);
                }
              });
            },
            secondary: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteFile(file),
                ),
                IconButton(
                  icon: Icon(
                      file.isPublic ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => _togglePublic(file),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareFile(file),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCollapsibleList({
    required String title,
    required List<SpectFile> fileList,
    required List<SpectFile> selectedFilesList,
  }) {
    return ExpansionTile(
      title: Text(title),
      children: fileList.isEmpty
          ? [const Center(child: Text("No files to display."))]
          : fileList.map((file) {
              return CheckboxListTile(
                title: Text(file.filename),
                value: selectedFilesList.contains(file),
                onChanged: (isSelected) {
                  setState(() {
                    if (isSelected == true) {
                      selectedFilesList.add(file);
                    } else {
                      selectedFilesList.remove(file);
                    }
                  });
                },
              );
            }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // User Files Section
            _buildUserFilesSection(),

            // Shared Files Section
            _buildCollapsibleList(
              title: "Shared Files",
              fileList: sharedFiles,
              selectedFilesList: selectedSharedFiles,
            ),

            // Public Files Section
            _buildCollapsibleList(
              title: "Public Files",
              fileList: publicFiles,
              selectedFilesList: selectedPublicFiles,
            ),

            // Draw Plots Button
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ElevatedButton(
                onPressed: () {
                  final allSelectedFiles = [
                    ...selectedFiles,
                    ...selectedSharedFiles,
                    ...selectedPublicFiles,
                  ];
                  _onDrawPlots(allSelectedFiles);
                },
                child: const Text("Draw Plots"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
