import 'package:flutter/material.dart';
import 'package:simple_login/database/DatabaseHelper.dart';
import 'package:simple_login/model/ResourceModel.dart';
import 'package:simple_login/model/UserModel.dart';

final signupKey = GlobalKey<FormState>();
TextEditingController email = new TextEditingController();
TextEditingController password = new TextEditingController();
var hidePassword = true;
var termsAgreement = false;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      Text(
                        "Be a budget savvy",
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Form(
                        key: signupKey,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email is required";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            Text("Password"),
                            TextFormField(
                              controller: password,
                              obscureText: hidePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password is required";
                                }
                                if (value.length < 8) {
                                  return "Password must be 8 characters above";
                                }
                                return null;
                              },
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
                            SizedBox(height: 30),
                            CheckboxListTile(
                              title: Text(
                                "I hereby agree with the terms and condition",
                                style: TextStyle(fontSize: 10),
                              ),
                              value: termsAgreement,
                              onChanged: (value) {
                                setState(() {
                                  termsAgreement = value!;
                                });
                              },
                              contentPadding: EdgeInsets.all(0),
                              visualDensity: VisualDensity.compact,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!termsAgreement) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "User must read and accept terms and condition",
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (signupKey.currentState!.validate()) {
                                    signupKey.currentState!.save();
                                    final user = UserModel(
                                      email: email.text,
                                      password: password.text,
                                    );
                                    int result =
                                        await DatabaseHelper.CREATE_USER(user);
                                    if (result > 0) {
                                      await DatabaseHelper.INIT_RESOURCES(
                                        Resourcemodel(
                                          title: "Cash",
                                          id: result,
                                          balance: 0,
                                        ),
                                      );
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          result > 0 ? "Success" : "error",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text("Sign Up"),
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
                      Text("Already have an account? Login here"),
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
