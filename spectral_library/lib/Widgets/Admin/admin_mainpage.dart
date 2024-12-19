import 'package:flutter/material.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Controllers/admin_controller.dart';

class AdminMainpage extends StatefulWidget {
  final User user;
  AdminMainpage(this.user, {Key? key}) : super(key: key);

  @override
  _AdminMainpageState createState() => _AdminMainpageState();
}

class _AdminMainpageState extends State<AdminMainpage> {
  int userCount = 0;
  int fileCount = 0;
  int folderCount = 0;
  Map<String, double> fileCategoryRatios = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    setState(() => isLoading = true);

    var userCountResponse = await AdminController.getUserCount(widget.user);
    var fileCountResponse = await AdminController.getFileCount(widget.user);
    var folderCountResponse = await AdminController.getFolderCount(widget.user);
    var fileCategoryRatiosResponse =
        await AdminController.getFileCategoryRatios(widget.user);

    if (userCountResponse.isSuccess) {
      userCount = userCountResponse.body as int;
    }
    if (fileCountResponse.isSuccess) {
      fileCount = fileCountResponse.body as int;
    }
    if (folderCountResponse.isSuccess) {
      folderCount = folderCountResponse.body as int;
    }
    if (fileCategoryRatiosResponse.isSuccess) {
      fileCategoryRatios = Map<String, double>.from(fileCategoryRatiosResponse.body);
    }

    setState(() => isLoading = false);
  }

  Widget _buildCategoryRatioList() {
    return Column(
      children: fileCategoryRatios.entries.map((entry) {
        return ListTile(
          title: Text(entry.key),
          trailing: Text("${(entry.value * 100).toStringAsFixed(2)}%"),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  ListTile(
                    title: const Text("Registered Users"),
                    trailing: Text(userCount.toString()),
                  ),
                  ListTile(
                    title: const Text("Total Files"),
                    trailing: Text(fileCount.toString()),
                  ),
                  ListTile(
                    title: const Text("Total Folders"),
                    trailing: Text(folderCount.toString()),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "File Category Ratios",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildCategoryRatioList(),
                ],
              ),
            ),
    );
  }
}