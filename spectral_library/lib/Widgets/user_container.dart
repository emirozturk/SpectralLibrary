import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Widgets/folder_page.dart';
import 'package:spectral_library/Widgets/upload_file_page.dart';
import 'package:spectral_library/Widgets/user_mainpage.dart';

class UserContainer extends StatefulWidget {
  final User user;
  const UserContainer(this.user, {super.key});
  @override
  State<UserContainer> createState() => _UserContainerState();
}

class _UserContainerState extends State<UserContainer> {
  final storage = const FlutterSecureStorage();
  var currentIndex = 0;
  int unreadMessageCount = 0;
  List<Widget> pageListFunc() => [
        UserMainpage(widget.user),
        UploadFilePage(widget.user),
        FolderPage(widget.user),
      ];

  void changePage(var index) async {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var pageList = pageListFunc();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.email,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: pageList[currentIndex],
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Mainpage"),
          NavigationDestination(
              icon: Icon(Icons.upload_file), label: "Upload File"),
          NavigationDestination(
            icon: Icon(Icons.folder),
            label: "Folders",
          ),
        ],
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => changePage(index),
      ),
    );
  }
}
