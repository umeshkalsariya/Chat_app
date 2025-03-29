import 'package:chat_app/screens/chat_list/chat_list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  static LoginController get to => Get.find<LoginController>();

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var isLoading = false.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> saveUserData(User user) async {
    await firestore.collection("users").doc(user.uid).set({
      "uid": user.uid,
      "name": user.displayName ?? "Anonymous",
      "email": user.email,
      "photoUrl": user.photoURL ?? "",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // Login with Email & Password
  Future<void> loginWithEmail() async {
    try {
      isLoading(true);
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await saveUserData(userCredential.user!);

      Get.offAll(() => ChatListScreen());
      Get.snackbar("Success", "Login Successful");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Login with Google
  Future<void> loginWithGoogle() async {
    try {
      isLoading(true);
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading(false);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await auth.signInWithCredential(credential);
      await saveUserData(userCredential.user!);
      Get.offAll(() => ChatListScreen());
      Get.snackbar("Success", "Google Sign-In Successful");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
