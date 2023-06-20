import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_catering_service/utils/extensions.dart';

import '../../utils/my_print.dart';
import '../../utils/my_toast.dart';
import '../../utils/my_utils.dart';

class AuthenticationRepository {
  //Will Sing in with google
  //If Sign in success, will return User Object else return null
  Future<User?> signInWithGoogle({required BuildContext context}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AuthenticationRepository().signInWithGoogle() called", tag: tag);

    //region Get Google SignIn Account
    GoogleSignInAccount? googleSignInAccount;
    try {
      googleSignInAccount = await GoogleSignIn().signIn();
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Google Sign In in AuthenticationRepository().signInWithGoogle():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
    MyPrint.printOnConsole("Final googleSignInAccount:$googleSignInAccount", tag: tag);

    if (googleSignInAccount == null) {
      MyPrint.printOnConsole("Returning from AuthenticationRepository().signInWithGoogle() because googleSignInAccount is null", tag: tag);
      return null;
    }
    //endregion

    //region Get Google SignIn Auth Credential
    AuthCredential? credential;
    try {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Getting AuthCredential for Google Sign In in AuthenticationRepository().signInWithGoogle():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
    MyPrint.printOnConsole("Final credential:$credential", tag: tag);

    if (credential == null) {
      MyPrint.printOnConsole("Returning from AuthenticationRepository().signInWithGoogle() because AuthCredential is null", tag: tag);
      return null;
    }
    //endregion

    //region Get Google SignIn User Credential
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential.user;
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
    //endregion

    return null;
  }
}