import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_catering_service/utils/extensions.dart';

import '../../utils/my_print.dart';
import '../../utils/my_toast.dart';

class AuthenticationRepository {
  //Will Sing in with google
  //If Sign in success, will return User Object else return null
  Future<User?> signInWithGoogle({required BuildContext context}) async {
    GoogleSignInAccount? googleSignInAccount;

    try {
      googleSignInAccount = await GoogleSignIn().signIn();
    }
    catch(e) {
      MyPrint.printOnConsole("Error in Google Sign In:$e");
      return null;
    }

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        return userCredential.user!;
      }
      on FirebaseAuthException catch (e) {
        MyPrint.printOnConsole("Code:${e.code}");
        switch (e.code) {
          case "account-exists-with-different-credential" :
            {
              List<String> methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(e.email!);
              MyPrint.printOnConsole("Methods:$methods");

              MyPrint.printOnConsole("Message:Account Already Exist With Different Method");
              if(context.checkMounted() && context.mounted) MyToast.showError(context: context, msg: "Account Already Exist With Different Method");
            }
            break;

          case "invalid-credential" :
            {
              MyPrint.printOnConsole("Message:Invalid Credentials");
              if(context.checkMounted() && context.mounted) MyToast.showError(context: context, msg: "Invalid Credentials");
            }
            break;

          case "operation-not-allowed" :
            {
              MyPrint.printOnConsole("Message:${e.message}");
              if(context.checkMounted() && context.mounted) MyToast.showError(context: context, msg: "${e.message}");
            }
            break;

          case "user-disabled" :
            {
              MyPrint.printOnConsole("Message:${e.message}");
              if(context.checkMounted() && context.mounted) MyToast.showError(context: context, msg: "${e.message}");
            }
            break;

          case "user-not-found" :
            {
              MyPrint.printOnConsole("Message:${e.message}");
              if(context.checkMounted() && context.mounted) MyToast.showError(context: context, msg: "${e.message}");
            }
            break;

          case "wrong-password" :
            {
              MyPrint.printOnConsole("Message:${e.message}");
              if(context.checkMounted() && context.mounted) MyToast.showError(context: context, msg: "${e.message}");
            }
            break;

          default :
            {
              MyPrint.printOnConsole("Message:${e.message}");
              if(context.checkMounted() && context.mounted) MyToast.showError(context: context, msg: "${e.message}");
            }
        }
      }

      return null;
    }
    return null;
  }
}