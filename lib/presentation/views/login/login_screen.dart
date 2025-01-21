import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkware/controllers/user_controller.dart';
import 'package:parkware/presentation/views/home/home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFC7E5C4), Color(0xFF70A288)],
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/parkware_login_2.png',
                  width: 200,
                ),
                SizedBox(height: 30),
                Text(
                  'Parkware',
                  style: textTheme.headline4?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "¡Comienza tu aventura ahora!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final user = await UserController.loginWithGoogle();
                      if (user != null && mounted) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const HomePage()));
                      }
                    } on FirebaseAuthException catch (error) {
                      print(error.message);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          error.message ?? "Something went wrong",
                        ),
                      ));
                    } catch (error) {
                      print(error);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          error.toString(),
                        ),
                      ));
                    }
                  },
                  icon: Icon(Icons.account_circle),
                  label: Text(
                    "Iniciar sesión con Google",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    // primary: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
