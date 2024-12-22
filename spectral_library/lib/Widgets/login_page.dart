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
import 'package:easy_localization/easy_localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final storage = const FlutterSecureStorage();
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  /// Attempt to login the user
  void login(BuildContext context, String email, String password) async {
    Response response = await UserController.getUser(email, password);
    if (response.isSuccess) {
      User user = User.fromMap(response.body);
      await storage.write(key: 'email', value: mailController.text);
      await storage.write(key: 'password', value: password);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => user.type == UserType.admin
              ? AdminContainer(user)
              : UserContainer(user),
        ),
      );
    } else {
      Util.showErrorDialog(context: context, content: response.message!);
    }
  }

  /// Automatically try to login if credentials are stored
  Future<void> autoLogin() async {
    String? email = await storage.read(key: 'email');
    String? password = await storage.read(key: 'password');
    if (email != null &&
        password != null &&
        email.isNotEmpty &&
        password.isNotEmpty) {
      login(context, email, password);
    }
  }

  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    // Current locale
    final Locale currentLocale = context.locale;

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Modern, flag-based language selector
              Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // English flag
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
                    // Turkish flag
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
              ),

              // Logo
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 150,
                  width: 150,
                ),
              ),

              // Title
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "login_page.title".tr(),
                    style: const TextStyle(fontSize: 32),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Email field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.perm_identity),
                    hintText: "login_page.email_hint".tr(),
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  controller: mailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      // Example validation with translation
                      return "error.email_required".tr();
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Password field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.key),
                    hintText: "login_page.password_hint".tr(),
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "error.password_required".tr();
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Login button
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    login(
                      context,
                      mailController.text,
                      Util.calculateMD5(passwordController.text),
                    );
                  }
                },
                style: Theme.of(context).elevatedButtonTheme.style,
                child: Text(
                  "login_page.login_button".tr(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPassword(
                        mail: mailController.text,
                      ),
                    ),
                  ),
                  child: Text(
                    "login_page.forgot_password".tr(),
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
                    "login_page.register".tr(),
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
