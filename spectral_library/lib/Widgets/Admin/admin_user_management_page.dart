import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/user_controller.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Models/user_type.dart';

class AdminUserManagementPage extends StatefulWidget {
  final User currentUser;

  AdminUserManagementPage(this.currentUser, {Key? key}) : super(key: key);

  @override
  _AdminUserManagementPageState createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  List<User> users = [];
  List<User> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);
    var response = await UserController.getUsers(widget.currentUser);
    if (response.isSuccess) {
      users =
          (response.body as List<dynamic>).map((x) => User.fromMap(x)).toList();
      filteredUsers = List.from(users);
    }
    setState(() => isLoading = false);
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where(
              (user) => user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addOrEditUser({User? user}) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController emailController =
            TextEditingController(text: user?.email ?? "");
        final TextEditingController companyController =
            TextEditingController(text: user?.company ?? "");
        final TextEditingController passwordController =
            TextEditingController(text: user?.password ?? "");

        return AlertDialog(
          title: Text(user == null ? "Add User" : "Edit User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: companyController,
                decoration: InputDecoration(labelText: "Company"),
              ),
              if (user == null) // Password only for new users
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (user == null) {
                  var newUser = User(
                    email: emailController.text,
                    company: companyController.text,
                    password: passwordController.text,
                    isConfirmed: true,
                    type: user?.type ?? UserType.user,
                  );
                  var response = await UserController.register(newUser);
                  if (response.isSuccess) {
                    setState(() => _fetchUsers());
                  }
                } else {
                  user.email = emailController.text;
                  user.company = companyController.text;
                  var response = await UserController.updateUser(user);
                  if (response.isSuccess) {
                    setState(() => _fetchUsers());
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content:
            Text("Are you sure you want to delete the user '${user.email}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              var response = await UserController.deleteUser(
                  widget.currentUser, user.email);
              if (response.isSuccess) {
                setState(() => _fetchUsers());
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _toggleUserConfirmation(User user) async {
    user.isConfirmed = !user.isConfirmed;
    var response = await UserController.updateUser(user);
    if (response.isSuccess) {
      setState(() => _fetchUsers());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "User '${user.email}' is now ${user.isConfirmed ? "confirmed" : "not confirmed"}.",
          ),
        ),
      );
    }
  }

  Widget _buildUserItem(User user) {
    return ListTile(
      title: Text(user.email),
      subtitle:
          Text("Company: ${user.company}\nConfirmed: ${user.isConfirmed}"),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Users",
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
                      children: filteredUsers
                          .map((user) => _buildUserItem(user))
                          .toList(),
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
