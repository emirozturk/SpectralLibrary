import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/category_controller.dart';
import 'package:spectral_library/Controllers/user_controller.dart';
import 'package:spectral_library/Models/category.dart';
import 'package:spectral_library/Models/folder.dart';
import 'package:spectral_library/Models/spect_file.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Widgets/draw_plot_page.dart';
import 'package:easy_localization/easy_localization.dart';

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

  // Helper method for localized category names
  String getLocalizedCategoryName(Category category) {
    return context.locale.languageCode == 'en'
        ? category.categoryNameEn
        : category.categoryNameTr;
  }

  Future<void> _fetchInitialData() async {
    final categoryResponse =
        await CategoryController.getCategories(widget.user);
    if (categoryResponse.isSuccess) {
      categories = (categoryResponse.body as List<dynamic>)
          .map((x) => Category.fromMap(x))
          .toList();
    }

    folders = widget.user.folders ?? [];
    files = folders
        .map((x) => x.files)
        .expand((list) => list ?? <SpectFile>[])
        .toList();

    final sharedFilesResponse =
        await UserController.getSharedFiles(widget.user);
    if (sharedFilesResponse.isSuccess) {
      sharedFiles = (sharedFilesResponse.body as List<dynamic>)
          .map((x) => SpectFile.fromMap(x))
          .toList();
    }

    final publicFilesResponse =
        await UserController.getPublicFiles(widget.user);
    if (publicFilesResponse.isSuccess) {
      publicFiles = (publicFilesResponse.body as List<dynamic>)
          .map((x) => SpectFile.fromMap(x))
          .toList();
    }

    final usersResponse = await UserController.getUsers(widget.user);
    if (usersResponse.isSuccess) {
      allUsers = (usersResponse.body as List<dynamic>)
          .map((x) => User.fromMap(x))
          .toList();
    }

    setState(() {});
  }

  Future<void> _deleteFile(SpectFile file) async {
    setState(() {
      for (var folder in widget.user.folders ?? []) {
        folder.files?.removeWhere((f) => f.filename == file.filename);
      }
      files.remove(file);
    });
    await UserController.updateUser(widget.user, widget.user);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("user_mainpage.file_deleted".tr())),
    );
  }

  Future<void> _togglePublic(SpectFile file) async {
    setState(() {
      file.isPublic = !file.isPublic;
    });
    await UserController.updateUser(widget.user, widget.user);

    // "File '{filename}' is now {status}."
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "user_mainpage.file_is_now".tr(
            namedArgs: {
              "filename": file.filename,
              "status": file.isPublic
                  ? "user_mainpage.public".tr()
                  : "user_mainpage.private".tr()
            },
          ),
        ),
      ),
    );
  }

  Future<void> _shareFile(SpectFile file) async {
    final selectedUserEmails = file.sharedWith?.toSet() ?? {};
    final TextEditingController searchController = TextEditingController();
    List<User> filteredUsers = allUsers;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Share File: ${file.filename}"),
          content: StatefulBuilder(
            builder: (ctx, setStateSB) {
              return SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Field
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: "user_mainpage.search_users".tr(),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setStateSB(() {
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
                          ? Center(
                              child: Text("user_mainpage.no_users_found".tr()))
                          : ListView(
                              shrinkWrap: true,
                              children: filteredUsers.map((user) {
                                final isSelected =
                                    selectedUserEmails.contains(user.email);
                                return CheckboxListTile(
                                  title: Text(user.email),
                                  value: isSelected,
                                  onChanged: (selected) {
                                    setStateSB(() {
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
              child: Text(
                  "folder_page.cancel".tr()), // or "Cancel" from user_mainpage
            ),
            TextButton(
              onPressed: () async {
                file.sharedWith = selectedUserEmails.toList();
                await UserController.updateUser(widget.user, widget.user);
                Navigator.pop(context);

                // "File '{filename}' shared successfully."
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "user_mainpage.file_shared".tr(
                        namedArgs: {"filename": file.filename},
                      ),
                    ),
                  ),
                );
              },
              child: Text("admin_category_management.save".tr()),
              // or "Save" from a different key
            ),
          ],
        );
      },
    );
  }

  void _onDrawPlots(List<SpectFile> allSelectedFiles) {
    if (allSelectedFiles.isEmpty) {
      // "No files selected for plotting."
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("user_mainpage.no_files_selected".tr())),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrawPlotPage(selectedFiles: allSelectedFiles),
      ),
    );
  }

  Widget _buildUserFilesSection() {
    return ExpansionTile(
      title: Text("user_mainpage.your_files".tr()),
      children: [
        ...files.map((file) {
          return CheckboxListTile(
            title: Text(file.filename),
            subtitle: Text(
              "Category: ${getLocalizedCategoryName(file.category)}, Public: ${file.isPublic}",
            ),
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
                    file.isPublic ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => _togglePublic(file),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareFile(file),
                ),
              ],
            ),
          );
        })
      ],
    );
  }

  Widget _buildCollapsibleList({
    required String titleKey,
    required List<SpectFile> fileList,
    required List<SpectFile> selectedList,
  }) {
    return ExpansionTile(
      title: Text(titleKey.tr()),
      children: fileList.isEmpty
          ? [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("user_mainpage.no_files".tr()),
                ),
              )
            ]
          : fileList.map((file) {
              return CheckboxListTile(
                title: Text(file.filename),
                value: selectedList.contains(file),
                onChanged: (isSelected) {
                  setState(() {
                    if (isSelected == true) {
                      selectedList.add(file);
                    } else {
                      selectedList.remove(file);
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
              titleKey: "user_mainpage.shared_files",
              fileList: sharedFiles,
              selectedList: selectedSharedFiles,
            ),

            // Public Files Section
            _buildCollapsibleList(
              titleKey: "user_mainpage.public_files",
              fileList: publicFiles,
              selectedList: selectedPublicFiles,
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
                child: Text("user_mainpage.draw_plots".tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
