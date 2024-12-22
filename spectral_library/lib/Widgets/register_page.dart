import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/user_controller.dart';
import 'package:spectral_library/Models/response.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Models/user_type.dart';
import 'package:spectral_library/util.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text controllers
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final retypePasswordController = TextEditingController();
  final companyController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // List of supported locales for language switching
  final List<Locale> locales = const [Locale('en'), Locale('tr')];

  /// Register logic
  Future<void> register(BuildContext context, String mail, String password,
      String passwordCheck, String company) async {
    User newUser = User(
      email: mail,
      password: Util.calculateMD5(password),
      company: company,
      type: UserType.user,
      isConfirmed: false,
    );

    Response response = await UserController.register(newUser);
    if (response.isSuccess) {
      // Make sure to await the showInfoDialog call
      await Util.showInfoDialog(context: context, content: response.message!);

      // Check if the widget is still mounted (user hasn’t navigated away),
      // then pop this register page
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      // Show error dialog on failure
      Util.showErrorDialog(context: context, content: response.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text("register_page.title".tr()),
        actions: [
          // Row of flags
          Row(
            children: [
              // US Flag
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
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 100,
                  width: 100,
                ),
              ),

              // E-Mail field
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: mailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "errors.email_required".tr();
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    icon: const Icon(Icons.email),
                    hintText: "register_page.email_hint".tr(),
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              // Password field
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "errors.password_required".tr();
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock),
                    hintText: "register_page.password_hint".tr(),
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              // Re-type Password field
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: retypePasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "errors.password_required".tr();
                    } else if (value != passwordController.text) {
                      return "errors.password_mismatch".tr();
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock_reset),
                    hintText: "register_page.retype_hint".tr(),
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              // Company field
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: companyController,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "errors.company_required".tr();
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    icon: const Icon(Icons.business),
                    hintText: "register_page.company_hint".tr(),
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              // Register button
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    register(
                      context,
                      mailController.text,
                      passwordController.text,
                      retypePasswordController.text,
                      companyController.text,
                    );
                  }
                },
                child: Text(
                  "register_page.register_button".tr(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
