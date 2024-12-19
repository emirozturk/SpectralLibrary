import 'package:flutter/material.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Widgets/Admin/admin_category_management_page.dart';
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
        AdminUserManagementPage(widget.user),
        AdminCategoryManagementPage(widget.user),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "MainPage"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Users"),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: "Categories"),
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
