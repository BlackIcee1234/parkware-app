import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:parkware/controllers/user_controller.dart';
import 'package:parkware/config/constants/firebase_options.dart';
import 'package:parkware/presentation/views/home/home_screen.dart';
import 'package:parkware/presentation/views/login/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:parkware/config/constants/environment.dart';
import 'package:parkware/presentation/views/splash_screen.dart';

Future<void> initializeDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();

  // * Initialize Environment variables
  await dotenv.load(fileName: ".env");

  // * Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // * Initialize Stripe
  Stripe.publishableKey = Environment.stripePublishableKey;
  Stripe.instance.applySettings();
}

Future<void> main() async {
  await initializeDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent,),
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: FutureBuilder(
        future: Future.delayed(Duration(seconds: 3)), // Espera 3 segundos antes de mostrar la página de inicio de sesión o la página principal
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen(); // Muestra la pantalla de inicio (splash screen)
          } else {
            return Stack(
              children: [
                UserController.user != null ? const HomePage() : const LoginPage()
              ],
            );
          }
        },
      ),
    );
  }
}