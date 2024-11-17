import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/user_controller.dart';
import 'package:spectral_library/util.dart';

class ForgotPassword extends StatefulWidget {
  String? mail;
  ForgotPassword({this.mail, super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  var mailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> resetPassword(context) async {
    var result = await UserController.resetPassword(mailController.text);
    if (result.isSuccess) {
      Util.showInfoDialog(context: context, content: result.body);
    } else {
      Util.showErrorDialog(context: context, content: result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.mail != null ? mailController.text = widget.mail! : "";
    return Form(
      key: formKey,
      child: Scaffold(
        appBar: AppBar(
            title: Text(
          "Şifremi Unuttum", //TODO: multilingual
          style: Theme.of(context).textTheme.bodyLarge,
        )),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  "assets/images/Logo.png",
                  height: 150,
                  width: 150,
                ),
              ),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mail girilmelidir.'; //Todo: multilingual
                    }
                    return null;
                  },
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.perm_identity),
                    hintText: "E-mail", //Todo: multilingual
                    border: InputBorder.none,
                  ),
                  controller: mailController,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    resetPassword(context)
                        .then((value) => Navigator.pop(context));
                  }
                },
                child: const Text("Sıfırla"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
