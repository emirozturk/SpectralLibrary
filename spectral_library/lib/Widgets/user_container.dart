import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easy_localization/easy_localization.dart'; // Localization
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
    final currentLocale = context.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.email,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          // Language Selection with Flags
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
                'assets/images/flags/en.png', // English flag image
                width: 40,
                height: 40,
              ),
            ),
          ),
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
                'assets/images/flags/tr.png', // Turkish flag image
                width: 40,
                height: 40,
              ),
            ),
          ),
        ],
      ),
      body: pageList[currentIndex],
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home),
              label: "user_container.mainpage".tr()), // Localized
          NavigationDestination(
              icon: const Icon(Icons.upload_file),
              label: "user_container.upload_file".tr()), // Localized
          NavigationDestination(
              icon: const Icon(Icons.folder),
              label: "user_container.folders".tr()), // Localized
        ],
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => changePage(index),
      ),
    );
  }
}
