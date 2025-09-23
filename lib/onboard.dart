import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ktea/api_service.dart';
import 'package:ktea/storage.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String selected = "Login";
  bool isLoading = false;

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/logo.png',
                          width: 200,
                          height: 200,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Login/Register toggle
                      CupertinoSegmentedControl<String>(
                        padding: const EdgeInsets.all(8),
                        borderColor: Colors.grey,
                        selectedColor: Colors.grey.shade300,
                        unselectedColor: Colors.white,
                        pressedColor: Colors.blueGrey.withOpacity(0.2),
                        children: const {
                          "Login": Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Text("Login"),
                          ),
                          "Register": Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Text("Register"),
                          ),
                        },
                        onValueChanged: (val) {
                          setState(() {
                            selected = val;
                            username.clear();
                            password.clear();
                          });
                        },
                        groupValue: selected,
                      ),
                      const SizedBox(height: 20),

                      // Login fields
                      if (selected == "Login") ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          child: TextField(
                            controller: username,
                            decoration: const InputDecoration(
                              labelText: "Username",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          child: TextField(
                            controller: password,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // Login/Register button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  if (selected == "Login") {
                                    // LOGIN FLOW
                                    final res = await ApiService.loginUser(
                                      username.text,
                                      password.text,
                                    );
                                    print("✅ Login Success: $res");
                                    String userId = '';
                                      if (res['_id'] != null && res['_id'] is Map && res['_id'].containsKey('\$oid')) {
                                        userId = res['_id']['\$oid']; 
                                      }

                                      // Extract username safely
                                      //String username = res['username'] ?? '';
                                     await saveLoginData(userId, res['username']);
                                     print("_id type: ${res['_id'].runtimeType}");     // prints type of _id
                                     print("_id value: ${res['_id']}"); 
                                    Navigator.pushReplacementNamed(context, "/MAIN");
                                    } else {
                                    // REGISTER FLOW
                                    final res = await ApiService.registerUser();
                                    print("✅ Register Success: $res");
                                   String userId = '';
                                      if (res['_id'] != null && res['_id'] is Map && res['_id'].containsKey('\$oid')) {
                                        userId = res['_id']['\$oid'];  // "68c5a656e62edd3b5ca6f857"
                                      }

                                      // Extract username safely
                                      //String username = res['username'] ?? '';
                                      print("_id type: ${res['_id'].runtimeType}");     // prints type of _id
                                      print("_id value: ${res['_id']}"); 
                                     await saveLoginData(userId, res['username']);


                                    // Show dialog with credentials
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text("Your Credentials"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("Username: ${res['username']}"),
                                              Text("Password: ${res['password']}"),
                                              const SizedBox(height: 10),
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  Clipboard.setData(ClipboardData(
                                                    text:
                                                        "Username: ${res['username']}\nPassword: ${res['password']}",
                                                  ));
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                        content:
                                                            Text("Credentials copied")),
                                                  );
                                                },
                                                icon: const Icon(Icons.copy),
                                                label: const Text("Copy"),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context); // close dialog
                                                Navigator.pushReplacementNamed(
                                                    context, "/MAIN");
                                              },
                                              child: const Text("Continue"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                } catch (e) {
                                  print("❌ Error: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e")),
                                  );
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                selected == "Login" ? "Login" : "Register",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Lottie animation at bottom
              Lottie.asset(
                'assets/rainbow.json',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
