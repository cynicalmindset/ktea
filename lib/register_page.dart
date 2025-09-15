import 'package:flutter/material.dart';
import 'package:ktea/api_service.dart';
import 'package:ktea/storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose(){
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: content(),
    );
  }

  Widget content() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Image.asset(
                'assets/logo.png',
                width: 200,
                height: 200,
              ),
              SizedBox(height: 20),

              // Name TextField
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),

              // Password TextField
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),

              // Buttons side by side
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async{
                        String username = _nameController.text.trim();
                        String password = _passwordController.text.trim();

                        if(username.isEmpty||password.isEmpty){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("nam password dal betichod")),
                          );
                          return;
                        }
                        try{
                          final userdata = await ApiService.loginUser(username, password);
                          print("party dede bhai: $userdata");
                          await saveLoginData(userdata['_id'], username, password);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("partyyyy: $userdata"))
                          );
                          Navigator.pushReplacementNamed(context, '/home');
                        }catch(e){
                          print("what the fuck: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("what the actual fuck: $e")),
                          );
                        }
                  
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Login'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async{
                        try{
                       final userdata = await ApiService.registerUser();
                       print("registered: $userdata");
                       await saveLoginData(userdata['_id'], userdata['username'], userdata['password']);
                       _nameController.text = userdata['username']??'';
                       _passwordController.text = userdata['password']??'';
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                                  content: Text(
                                    "areyh party!!\n"
                                    "username: ${userdata['username']}\n"
                                    "password: ${userdata['password']}\n"
                                    "user id: ${userdata['_id']}"
                                  ),
                                ),
                       );
                       Navigator.pushReplacementNamed(context, '/home');
                        } catch(e){
                          print("areyh bhnchod: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("ajji ni hua ji $e"))
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Register'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 120),

              // Note
              Text(
                'NOTE:\nRegister will generate Random Name and Password for Maintaining Privacy\n\n\nClicking on Register Will Take 10-12 Sec , wait kr le lawde',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
