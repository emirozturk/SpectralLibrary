import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/user_controller.dart';
import 'package:spectral_library/util.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgotPassword extends StatefulWidget {
  final String? mail;
  const ForgotPassword({this.mail, Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final mailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill the email if passed from the previous screen
    if (widget.mail != null) {
      mailController.text = widget.mail!;
    }
  }

  /// Reset password logic
  Future<void> resetPassword(BuildContext context) async {
    final result = await UserController.resetPassword(mailController.text);
    if (result.isSuccess) {
      // Show the success dialog and wait for user to press "OK"
      await Util.showInfoDialog(
          context: context, content: "general.success_message".tr());
      if (!mounted) return;
      Navigator.pop(context); // Return to the previous screen after dialog
    } else {
      // Show error dialog (not awaited, but you can await it if desired)
      Util.showErrorDialog(
        context: context,
        content: result.message!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  "assets/images/Logo.png",
                  height: 150,
                  width: 150,
                ),
              ),
              // Email field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: mailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      // "Mail girilmelidir." -> "forgot_page.mail_required"
                      return "forgot_page.mail_required".tr();
                    }
                    return null;
                  },
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.perm_identity),
                    // "E-mail" -> "forgot_page.email_hint"
                    hintText: "forgot_page.email_hint".tr(),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Reset button
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // We now only call resetPassword
                    resetPassword(context);
                  }
                },
                // "Sıfırla" -> "forgot_page.reset_button"
                child: Text("forgot_page.reset_button".tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
