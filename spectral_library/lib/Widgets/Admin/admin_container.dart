import 'package:flutter/material.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Widgets/Admin/admin_category_management_page.dart';
import 'package:spectral_library/Widgets/Admin/admin_file_management_page.dart';
import 'package:spectral_library/Widgets/Admin/admin_folder_management_page.dart';
import 'package:spectral_library/Widgets/Admin/admin_mainpage.dart';
import 'package:spectral_library/Widgets/Admin/admin_user_management_page.dart';

class AdminContainer extends StatefulWidget {
  final User user;
  const AdminContainer(this.user, {super.key});
  @override
  State<AdminContainer> createState() => _AdminContainerState();
}

class _AdminContainerState extends State<AdminContainer> {
  var currentIndex = 0;
  List<Widget> pageListFunc() => [
        AdminMainpage(widget.user),
        AdminFolderManagementPage(widget.user),
        AdminCategoryManagementPage(widget.user),
        AdminUserManagementPage(widget.user),
        AdminFileManagementPage(widget.user)
      ];

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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Anasayfa"),
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Kullanıcılar"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Mesajlar"),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}