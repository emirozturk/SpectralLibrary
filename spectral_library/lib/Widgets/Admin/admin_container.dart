import 'package:flutter/material.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Widgets/Admin/admin_category_management_page.dart';
import 'package:spectral_library/Widgets/Admin/admin_mainpage.dart';
import 'package:spectral_library/Widgets/Admin/admin_user_management_page.dart';
import 'package:easy_localization/easy_localization.dart';

class AdminContainer extends StatefulWidget {
  final User user;
  const AdminContainer(this.user, {super.key});

  @override
  State<AdminContainer> createState() => _AdminContainerState();
}

class _AdminContainerState extends State<AdminContainer> {
  int currentIndex = 0;

  List<Widget> pageListFunc() => [
        AdminMainpage(widget.user),
        AdminUserManagementPage(widget.user),
        AdminCategoryManagementPage(widget.user),
      ];

  @override
  Widget build(BuildContext context) {
    final pageList = pageListFunc();
    final currentLocale = context.locale; // to highlight active language

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.email,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          // English Flag
          InkWell(
            onTap: () => context.setLocale(const Locale('en')),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: currentLocale.languageCode == 'en'
                      ? Colors.blue
                      : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/flags/en.png',
                width: 40,
                height: 40,
              ),
            ),
          ),
          // Turkish Flag
          InkWell(
            onTap: () => context.setLocale(const Locale('tr')),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: currentLocale.languageCode == 'tr'
                      ? Colors.blue
                      : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/flags/tr.png',
                width: 40,
                height: 40,
              ),
            ),
          ),
        ],
      ),
      body: pageList[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "MainPage"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
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
