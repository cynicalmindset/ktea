import 'package:flutter/material.dart';
import 'package:ktea/home.dart';
import 'package:ktea/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Terms extends StatefulWidget {
  const Terms({super.key});

  @override
  State<Terms> createState() => _termsState();
}



class _termsState extends State<Terms> {




  void initState(){
    checkLogin();
    
  }

Future<void> checkLogin() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId'); // check userId instead of token

  if (userId != null) {
    // User is logged in → Go to Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Home()),
    );
  } else {
    // User not logged in → Go to Login (or Terms)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Terms & Condition", style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),textAlign: TextAlign.center),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text("Terms & Condition", style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),textAlign: TextAlign.center),
            SizedBox(height: 16),
            Expanded(child: SingleChildScrollView(
              child: 
             RichText(
  text: TextSpan(
    style: const TextStyle(color: Colors.black, fontSize: 16), // default style
    children: [
      const TextSpan(
        text: "Welcome to KTEA. ",
        
      ),
      const TextSpan(
        text: "By using this app, you agree to the following terms:\n\n\n",
      ),

      // Highlight section title
      const TextSpan(
        text: "1. Account & Identity\n\n",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      const TextSpan(
        text:
            "Your username and password are automatically generated.\n\nThese credentials cannot be changed or recovered. Please make sure you remember them.\n\nYour identity will always remain anonymous. Even the developers cannot see who you are.\n\n\n",
      ),

      const TextSpan(
        text: "2. Purpose of the App\n\n",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      const TextSpan(
        text:
            "This app is built for sharing fun, lighthearted “teas” and stories around campus.\n\nPlease use it only for this intended purpose (optional).\n\n\n",
      ),

      const TextSpan(
        text: "3. Community Guidelines\n\n",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      const TextSpan(
        text:
            "Keep the space friendly and respectful (optional).\n\nAvoid bullying, harassment, or targeting individuals (optional).\n\nMaintaining peace and positivity is encouraged (optional).\n\n\n",
      ),

      const TextSpan(
        text: "4 Responsibility\n\n",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ),
      const TextSpan(
        text:
            "You are solely responsible for the content you post.\n\nThe app creators are not liable for any posts, interactions, or disputes between users.\n\n\n",
      ),

      const TextSpan(
        text: "5. Limitations\n\n",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      const TextSpan(
        text:
            "Lost credentials cannot be retrieved. A new account will need to be generated if you lose them.\n\nThe app team reserves the right to remove content or restrict access if rules are violated.\n\n\n",
      ),

      const TextSpan(
        text: "6 Acceptance\n\n",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
      ),
      const TextSpan(
        text:
            "By using KTEA, you agree to these terms. If you do not agree, please do not use the app.",
      ),
    ],
  ),
)

            ),),SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(onPressed: (){
                Navigator.pushNamed(context, '/terms2');
              }, child: Text("damn ok")),
            )
          ],
        ),
      ),
    );
  }


  // Widget content(){
  //   return Container();
  // }


}