import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:spectral_library/Models/user.dart';

class UserMainpage extends StatelessWidget {
  User user;
  UserMainpage(this.user, {super.key});
  var categories;
  var subcategories;
  var folders;
  var files;
  var selectedCategory;
  var selectedSubcategory;
  var selectedFolder;
  var selectedFiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownSearch<String>(
          popupProps: const PopupProps.menu(
            showSearchBox: true,
          ),
          items: categories,
          onChanged: (value) => selectedCategory = value,
        ),
        DropdownSearch<String>(
          popupProps: const PopupProps.menu(
            showSearchBox: true,
          ),
          items: subcategories,
          onChanged: (value) => selectedSubcategory = value,
        ),
        DropdownSearch<String>(
          popupProps: const PopupProps.menu(
            showSearchBox: true,
          ),
          items: folders,
          onChanged: (value) => selectedFolder = value,
        ),
        DropdownSearch<String>.multiSelection(
          popupProps: const PopupPropsMultiSelection.menu(
            showSearchBox: true,
            showSelectedItems: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Dosya seçilmelidir';
            }
            return null;
          },
          items: files ?? [],
          selectedItems: selectedFiles,
          onChanged: (value) => selectedFiles = value,
        ),
      ],
    );
  }
}
