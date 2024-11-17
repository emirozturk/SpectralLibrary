import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/user_controller.dart';
import 'package:spectral_library/Models/response.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Models/user_type.dart';
import 'package:spectral_library/util.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var mailController = TextEditingController();
  var passwordController = TextEditingController();
  var retypePasswordController = TextEditingController();
  var companyController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  void register(BuildContext context, String mail, String password,
      String passwordCheck, String company) async {
    User newUser = User(
        email: mail,
        password: password,
        company: company,
        type: UserType.user,
        isConfirmed: false);
    Response response = await UserController.register(newUser);
    if (response.isSuccess) {
      Util.showInfoDialog(context: context, content: response.body);
    } else {
      Util.showErrorDialog(context: context, content: response.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
              child: Image.asset(
                "assets/images/logo.png",
                height: 150,
                width: 150,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mail girilmelidir.'; //Todo: multilingual
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.perm_identity),
                  hintText: "E-Mail",
                  border: InputBorder.none,
                  counterText: "",
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                controller: mailController,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Şifre girilmelidir.'; //Todo: multilingual
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.perm_identity),
                  hintText: "Password",
                  border: InputBorder.none,
                  counterText: "",
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                controller: passwordController,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Şifre girilmelidir.'; //Todo: multilingual
                  } else if (value != passwordController.text) {
                    return 'Şifre alanları aynı değil';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.perm_identity),
                  hintText: "Re-type Password",
                  border: InputBorder.none,
                  counterText: "",
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                controller: retypePasswordController,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Şifre girilmelidir.'; //Todo: multilingual
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.perm_identity),
                  hintText: "Company",
                  border: InputBorder.none,
                  counterText: "",
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                controller: companyController,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  register(
                      context,
                      mailController.text,
                      passwordController.text,
                      retypePasswordController.text,
                      companyController.text);
                }
              },
              style: Theme.of(context).elevatedButtonTheme.style,
              child: Text("Kayıt Ol",
                  style: Theme.of(context).textTheme.labelLarge),
            ),
          ],
        ),
      ),
    );
  }
}
