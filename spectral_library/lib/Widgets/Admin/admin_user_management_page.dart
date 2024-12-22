import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/user_controller.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Models/user_type.dart';
import 'package:spectral_library/util.dart'; // for Util.calculateMD5
import 'package:easy_localization/easy_localization.dart';

class AdminUserManagementPage extends StatefulWidget {
  final User currentUser;

  const AdminUserManagementPage(this.currentUser, {super.key});

  @override
  _AdminUserManagementPageState createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  List<User> users = [];
  List<User> filteredUsers = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);

    final response = await UserController.getUsers(widget.currentUser);
    if (response.isSuccess) {
      final list = response.body as List<dynamic>;
      users = list.map((x) => User.fromMap(x)).toList();
      filteredUsers = List.from(users);
    }

    setState(() => isLoading = false);
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where(
            (user) => user.email.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  /// ADD or EDIT a User
  void _addOrEditUser({User? user}) {
    showDialog(
      context: context,
      builder: (context) {
        // Controllers
        final emailController = TextEditingController(text: user?.email ?? "");
        final companyController =
            TextEditingController(text: user?.company ?? "");

        // If user is null, we will definitely need a password.
        // If user is existing, this field can be optional (if left empty => no change).
        final passwordController = TextEditingController();

        // For user type
        // If user == null (new user), default to 'user'
        UserType selectedType = user?.type ?? UserType.user;

        final isNew = (user == null);

        return AlertDialog(
          title: Text(
            isNew
                ? "admin_user_management.add_user".tr()
                : "admin_user_management.edit_user".tr(),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // EMAIL
                TextField(
                  controller: emailController,
                  readOnly: !isNew, // if existing user, cannot change email
                  decoration: InputDecoration(
                    labelText: "Email",
                  ),
                ),

                // COMPANY
                const SizedBox(height: 10),
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(
                    labelText: "admin_user_management.company".tr(),
                  ),
                ),

                // PASSWORD
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "admin_user_management.password".tr(),
                  ),
                  obscureText: true,
                ),

                // USER TYPE
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "admin_user_management.user_type".tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<UserType>(
                      value: selectedType,
                      items: [
                        DropdownMenuItem(
                          value: UserType.admin,
                          child: Text("admin_user_management.type_admin".tr()),
                        ),
                        DropdownMenuItem(
                          value: UserType.moderator,
                          child:
                              Text("admin_user_management.type_moderator".tr()),
                        ),
                        DropdownMenuItem(
                          value: UserType.user,
                          child: Text("admin_user_management.type_user".tr()),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedType = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("admin_user_management.cancel".tr()),
            ),
            TextButton(
              onPressed: () async {
                // Close dialog
                Navigator.pop(context);

                // If new user
                if (isNew) {
                  // Must have password
                  if (passwordController.text.isEmpty) {
                    // Possibly show a message or ignore
                    return;
                  }
                  final hashedPass = Util.calculateMD5(passwordController.text);
                  final newUser = User(
                    email: emailController.text,
                    company: companyController.text,
                    password: hashedPass, // hashed
                    isConfirmed: true,
                    type: selectedType,
                  );
                  final response = await UserController.register(newUser);
                  if (response.isSuccess) {
                    _fetchUsers();
                    setState(() {});
                  }
                } else {
                  // Existing user
                  // Email is ID, so we don't change it
                  user!.company = companyController.text;
                  user.type = selectedType;

                  // If passwordController is not empty => update
                  if (passwordController.text.isNotEmpty) {
                    user.password = Util.calculateMD5(passwordController.text);
                  }
                  final response =
                      await UserController.updateUser(widget.currentUser, user);
                  if (response.isSuccess) {
                    _fetchUsers();
                    setState(() {});
                  }
                }
              },
              child: Text("admin_user_management.save".tr()),
            ),
          ],
        );
      },
    );
  }

  /// DELETE a User
  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("admin_user_management.delete_user".tr()),
        content: Text(
          "admin_user_management.delete_user_question".tr(
            namedArgs: {"email": user.email},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("admin_user_management.cancel".tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final response = await UserController.deleteUser(
                widget.currentUser,
                user.email,
              );
              if (response.isSuccess) {
                _fetchUsers();
                setState(() {});
              }
            },
            child: Text("admin_user_management.delete_user".tr()),
          ),
        ],
      ),
    );
  }

  /// TOGGLE isConfirmed
  void _toggleUserConfirmation(User user) async {
    user.isConfirmed = !user.isConfirmed;
    final response = await UserController.updateUser(widget.currentUser, user);
    if (response.isSuccess) {
      _fetchUsers();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "admin_user_management.user_updated".tr(
              namedArgs: {
                "email": user.email,
                "status": user.isConfirmed
                    ? "admin_user_management.confirmed".tr()
                    : "admin_user_management.not_confirmed".tr(),
              },
            ),
          ),
        ),
      );
    }
  }

  Widget _buildUserItem(User user) {
    return ListTile(
      title: Text(user.email),
      subtitle: Text(
        "${"admin_user_management.company".tr()}: ${user.company}\n"
        "${"admin_user_management.confirmed".tr()}: ${user.isConfirmed}\n"
        "${"admin_user_management.user_type".tr()}: ${user.type}",
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _addOrEditUser(user: user),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteUser(user),
          ),
          IconButton(
            icon: Icon(
              user.isConfirmed ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () => _toggleUserConfirmation(user),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usually, we don't define an appBar here if it's inside a container with its own appBar.
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // "Search Users"
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "admin_user_management.search_users".tr(),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: _filterUsers,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: filteredUsers.map(_buildUserItem).toList(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditUser(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
