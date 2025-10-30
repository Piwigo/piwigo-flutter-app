import 'package:flutter/material.dart';
import 'package:piwigo_ng/ui/authentification/widgets/two_factor_auth_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final instanceURLTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //instanceURLTextController.addListener();
  }

  @override
  void dispose() {
    instanceURLTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16.0,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            Image(image: AssetImage('assets/piwigo_logo.png')),
            TextFormField(
              controller: instanceURLTextController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Login",
              ),
            ),
            TextFormField(
              controller: instanceURLTextController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Password",
              ),
            ),

            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TwoFactorAuthScreen()),
              ),
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
