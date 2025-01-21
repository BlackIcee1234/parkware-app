import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserController {
  static User? user = FirebaseAuth.instance.currentUser;

  static Future<User?> loginWithGoogle() async {
    final googleAccount = await GoogleSignIn().signIn();

    if (googleAccount == null) {
      // El usuario canceló el inicio de sesión con Google
      return null;
    }

    final googleAuth = await googleAccount.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    
    // Actualizar la instancia de usuario
    user = userCredential.user;

    return user;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    // Limpiar la instancia de usuario al cerrar sesión
    user = null;
  }

  // Método para obtener el UID del usuario actualmente autenticado
  static String getCurrentUserUid() {
    return user?.uid ?? "";
  }
}

