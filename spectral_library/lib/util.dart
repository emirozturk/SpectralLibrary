import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // For .tr()

class Util {
  /// MD5 Hash
  static String calculateMD5(String password) {
    List<int> bytes = utf8.encode(password);
    Digest md5Hash = md5.convert(bytes);
    return md5Hash.toString();
  }

  /// A custom dialog with two buttons (YES / NO)
  static void showCustomDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback function,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            // We assume `title` is also a localization key, e.g. "general.some_title"
            title.tr(),
            style: Theme.of(ctx)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            // Same assumption here: "general.some_message"
            content.tr(),
            style: Theme.of(ctx).textTheme.bodyMedium,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                function();
              },
              child: Text(
                'general.yes'.tr(), // "Evet" / "Yes"
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(
                'general.no'.tr(), // "Hayır" / "No"
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show an informational dialog (OK)
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String content, // e.g. "general.success_message"
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'general.success'.tr(), // "Başarılı" / "Success"
            style: Theme.of(ctx)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            content.tr(),
            style: Theme.of(ctx).textTheme.bodyMedium,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'general.ok'.tr(), // "Tamam" / "OK"
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show an error dialog (OK)
  static void showErrorDialog({
    required BuildContext context,
    required String content, // e.g. "general.error_message"
  }) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'general.failed'.tr(), // "Başarısız" / "Failed"
            style: Theme.of(ctx)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            content.tr(),
            style: Theme.of(ctx).textTheme.bodyMedium,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'general.ok'.tr(), // "Tamam" / "OK"
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }

/*
  // If needed, localize your snack bar too
  static void showErrorSnackBar(BuildContext context, String messageKey) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messageKey.tr()),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'general.ok'.tr(), // or 'general.close'.tr() etc.
          onPressed: () {},
        ),
      ),
    );
  }
*/
}
