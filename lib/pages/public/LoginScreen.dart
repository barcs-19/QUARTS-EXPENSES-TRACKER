import 'package:flutter/material.dart';
import 'package:simple_login/database/DatabaseHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_login/model/UserModel.dart';
import 'package:simple_login/pages/user/UserDashboard.dart';

final loginKey = GlobalKey<FormState>();
TextEditingController email = new TextEditingController();
TextEditingController password = new TextEditingController();
var hidePassword = true;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                color: Colors.blueAccent,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      Text(
                        "Welcome back!",
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Form(
                        key: loginKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Email"),
                            TextFormField(
                              controller: email,
                              decoration: InputDecoration(
                                hint: Text("eg. JohnDoe@Gmail.com"),
                                prefixIcon: Icon(Icons.email),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Password"),
                            TextFormField(
                              controller: password,
                              obscureText: hidePassword,
                              decoration: InputDecoration(
                                hint: Text("Must be 8 character above"),
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  },
                                  icon: Icon(
                                    hidePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [Text("Forgot password?")],
                              ),
                            ),
                            SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  UserModel? user =
                                      await DatabaseHelper.LOGIN_USER(
                                        email.text,
                                        password.text,
                                      );

                                  if (user == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Account doesn't exist"),
                                      ),
                                    );
                                    return;
                                  }

                                  final prefs =
                                      await SharedPreferences.getInstance();

                                  await prefs.setString(
                                    "password",
                                    user.password,
                                  );
                                  await prefs.setString("email", user.email);
                                  await prefs.setInt("id", user.id);
                                  await prefs.setBool("isLoggedIn", true);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Login Successfully"),
                                    ),
                                  );

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserDashboard(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Text("Login"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(flex: 1, child: SizedBox()),
                      Text("Doesn't have an account? Create one"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
