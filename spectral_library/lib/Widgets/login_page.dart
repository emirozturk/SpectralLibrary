import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spectral_library/Controllers/user_controller.dart';
import 'package:spectral_library/Models/response.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Models/user_type.dart';
import 'package:spectral_library/Widgets/Admin/admin_container.dart';
import 'package:spectral_library/Widgets/forgot_password.dart';
import 'package:spectral_library/Widgets/register_page.dart';
import 'package:spectral_library/Widgets/user_container.dart';
import 'package:spectral_library/util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final storage = const FlutterSecureStorage();

  var mailController = TextEditingController();
  var passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  void login(context, username, password) async {
    /*
    Response response = await UserController.getUser(username, password);
    if (response.isSuccess) {
      User user = response.body;
      await storage.write(key: 'email', value: mailController.text);
      await storage.write(
          key: 'password', value: Util.calculateMD5(passwordController.text));
    */
    var response = Response.success("");
    if (true) {
      var user = User(
          email: "emirozturk@trakya.edu.tr",
          company: "Trakya",
          isConfirmed: true,
          password: "123",
          type: UserType.user,
          folders: null,
          token: null,
          userId: 1);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => user.type == UserType.admin
              ? AdminContainer(user)
              : UserContainer(user),
        ),
      );
    } else {
      Util.showErrorSnackBar(context, response.message);
    }
  }

  Future<void> autoLogin() async {
    String? username = await storage.read(key: 'email');
    String? password = await storage.read(key: 'password');
    if (username != null && password != null) {
      login(context, username, password);
    }
  }

  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 150,
                  width: 150,
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "Spectral Library Database",
                        style: TextStyle(fontSize: 32),
                      ),
                    ],
                  ),
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
                  keyboardType: TextInputType.number,
                  /*
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mail girilmelidir.'; //Todo: multilingual
                    }
                    return null;
                  },*/
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  /*
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre girilmelidir.';
                    }
                    return null;
                  },*/
                  obscureText: true,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.key),
                    hintText: "Şifre",
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  controller: passwordController,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    login(
                        context, mailController.text, passwordController.text);
                  }
                },
                style: Theme.of(context).elevatedButtonTheme.style,
                child: Text("Giriş",
                    style: Theme.of(context).textTheme.labelLarge),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ForgotPassword(mail: mailController.text),
                    ),
                  ),
                  child: Text(
                    "Şifremi Unuttum",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  ),
                  child: Text(
                    "Kayıt Ol",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
