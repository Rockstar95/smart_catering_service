import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_catering_service/backend/admin_user/admin_user_controller.dart';
import 'package:smart_catering_service/backend/common/app_controller.dart';
import 'package:smart_catering_service/models/admin_user/data_model/admin_user_model.dart';
import 'package:smart_catering_service/utils/extensions.dart';
import 'package:smart_catering_service/utils/my_toast.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/user/data_model/user_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../../views/authentication/screens/login_screen.dart';
import '../../views/common/components/MyCupertinoAlertDialogWidget.dart';
import '../navigation/navigation_controller.dart';
import '../navigation/navigation_operation_parameters.dart';
import '../navigation/navigation_type.dart';
import '../user/user_controller.dart';
import 'authentication_provider.dart';
import 'authentication_repository.dart';

class AuthenticationController {
  late AuthenticationProvider _authenticationProvider;
  late AuthenticationRepository _authenticationRepository;

  AuthenticationController({
    required AuthenticationProvider? authenticationProvider,
    AuthenticationRepository? repository,
  }) {
    _authenticationProvider = authenticationProvider ?? AuthenticationProvider();
    _authenticationRepository = repository ?? AuthenticationRepository();
  }

  AuthenticationProvider get authenticationProvider => _authenticationProvider;

  AuthenticationRepository get authenticationRepository => _authenticationRepository;

  Future<bool> isUserLoggedIn() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AuthenticationController().isUserLoggedIn() called", tag: tag);

    AuthenticationProvider provider = authenticationProvider;

    User? firebaseUser = await FirebaseAuth.instance.authStateChanges().first;

    if (firebaseUser == null) {
      if (kIsWeb) {
        await Future.delayed(const Duration(seconds: 2));
        firebaseUser = await FirebaseAuth.instance.authStateChanges().first;
      }
    }

    MyPrint.printOnConsole("FirebaseUsr:$firebaseUser", tag: tag);

    if (firebaseUser != null && (firebaseUser.email ?? "").isNotEmpty) {
      provider.setAuthenticationDataFromFirebaseUser(
        firebaseUser: firebaseUser,
        isNotify: false,
      );
      return true;
    } else {
      logout();
      return false;
    }
  }

  Future<bool> checkUserWithIdExistOrNotAndIfNotExistThenCreate({
    required String userId,
  }) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AuthenticationController().checkUserWithIdExistOrNotAndIfNotExistThenCreate() called with userId:'$userId'", tag: tag);

    bool isUserExist = false;

    if (userId.isEmpty) {
      authenticationProvider.userModel.set(value: null, isNotify: false);
      return isUserExist;
    }

    try {
      if (AppController.isAdminApp) {
        AdminUserController adminUserController = AdminUserController();
        AdminUserModel? adminUserModel = await adminUserController.adminUserRepository.getAdminUserModelFromId(userId: userId);
        MyPrint.printOnConsole("adminUserModel:'$adminUserModel'", tag: tag);

        if (adminUserModel != null) {
          isUserExist = true;

          authenticationProvider.adminUserModel.set(value: adminUserModel, isNotify: false);
        } else {
          AdminUserModel createdUserModel = AdminUserModel(
            id: userId,
            email: authenticationProvider.email.get(),
          );
          bool isCreated = await adminUserController.createNewUser(userModel: createdUserModel);
          MyPrint.printOnConsole("isUserCreated:'$isCreated'", tag: tag);

          authenticationProvider.adminUserModel.set(value: isCreated ? createdUserModel : null, isNotify: false);
        }
      } else {
        UserController userController = UserController();
        UserModel? userModel = await userController.userRepository.getUserModelFromId(userId: userId);
        MyPrint.printOnConsole("userModel:'$userModel'", tag: tag);

        if (userModel != null) {
          isUserExist = true;

          authenticationProvider.userModel.set(value: userModel, isNotify: false);
        } else {
          UserModel createdUserModel = UserModel(
            id: userId,
            email: authenticationProvider.email.get(),
          );
          bool isCreated = await userController.createNewUser(userModel: createdUserModel);
          MyPrint.printOnConsole("isUserCreated:'$isCreated'", tag: tag);

          authenticationProvider.userModel.set(value: isCreated ? createdUserModel : null, isNotify: false);
        }
      }
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AuthenticationController().checkUserWithIdExistOrNotAndIfNotExistThenCreate():'$e'", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return isUserExist;
  }

  Future<bool> signInWithGoogle({required BuildContext context}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AuthenticationController().signInWithGoogle() called", tag: tag);

    AuthenticationProvider provider = authenticationProvider;

    User? user = await authenticationRepository.signInWithGoogle(context: context);
    MyPrint.printOnConsole("user:$user", tag: tag);

    provider.setAuthenticationDataFromFirebaseUser(firebaseUser: user, isNotify: false);

    bool isUserExist = await checkUserWithIdExistOrNotAndIfNotExistThenCreate(
      userId: user?.uid ?? "",
    );
    MyPrint.printOnConsole("isUserExist:$isUserExist", tag: tag);

    if (!isUserExist) {
      provider.userId.set(value: "");
    }

    return isUserExist;
  }

  //region User Stream Subscription
  Future<void> startUserSubscription() async {
    MyPrint.printOnConsole("AuthenticationController().startUserSubscription() called");

    AuthenticationProvider provider = authenticationProvider;

    String userId = provider.userId.get();

    if (userId.trim().isEmpty) {
      MyPrint.printOnConsole("Returning from AuthenticationController().startUserSubscription() because userId is empty");
      return;
    }

    Completer<bool> completer = Completer<bool>();

    if (AppController.isAdminApp) {
      provider.setUserStreamSubscription(
        subscription: FirebaseNodes.adminUserDocumentReference(userId: userId).snapshots().listen(
          (MyFirestoreDocumentSnapshot snapshot) async {
            MyPrint.printOnConsole("AdminUser stream snapshot:${snapshot.data()}");

            if (!completer.isCompleted) {
              completer.complete(true);
            }

            AdminUserModel? userModel;
            if (snapshot.exists && (snapshot.data() ?? {}).isNotEmpty) {
              userModel = AdminUserModel.fromMap(snapshot.data()!);
            }

            provider.userId.set(value: userModel?.id ?? "", isNotify: false);
            provider.adminUserModel.set(value: userModel, isNotify: true);
          },
          onDone: () {
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          onError: (Object e, StackTrace s) {
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          },
          cancelOnError: true,
        ),
        isCancelPreviousSubscription: true,
        isNotify: true,
      );
    } else {
      provider.setUserStreamSubscription(
        subscription: FirebaseNodes.userDocumentReference(userId: userId).snapshots().listen(
          (MyFirestoreDocumentSnapshot snapshot) async {
            MyPrint.printOnConsole("User stream snapshot:${snapshot.data()}");

            if (!completer.isCompleted) {
              completer.complete(true);
            }

            UserModel? userModel;
            if (snapshot.exists && (snapshot.data() ?? {}).isNotEmpty) {
              userModel = UserModel.fromMap(snapshot.data()!);
            }

            provider.userId.set(value: userModel?.id ?? "", isNotify: false);
            provider.userModel.set(value: userModel, isNotify: true);
          },
          onDone: () {
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          onError: (Object e, StackTrace s) {
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          },
          cancelOnError: true,
        ),
        isCancelPreviousSubscription: true,
        isNotify: true,
      );
    }

    await completer.future;

    MyPrint.printOnConsole("User Stream Started");
  }

  void stopUserSubscription() async {
    MyPrint.printOnConsole("AuthenticationController().stopUserSubscription() called");

    AuthenticationProvider provider = authenticationProvider;

    provider.resetData(isNotify: false);
  }

  //endregion

  Future<bool> logout({
    bool isShowConfirmationDialog = false,
    bool isNavigateToLogin = false,
    bool isForceLogout = false,
    String forceLogoutMessage = "",
  }) async {
    BuildContext? context = NavigationController.mainScreenNavigator.currentContext;

    bool? isLoggedOut;
    if (context != null && isShowConfirmationDialog) {
      isLoggedOut = await showDialog(
          context: context,
          builder: (context) {
            return MyCupertinoAlertDialogWidget(
              title: "Logout",
              description: "Are you sure want to logout?",
              neagtiveText: "No",
              positiveText: "Yes",
              negativeCallback: () => Navigator.pop(context, false),
              positiviCallback: () async {
                Navigator.pop(context, true);
              },
            );
          });
    } else {
      isLoggedOut = true;
    }
    MyPrint.printOnConsole("IsLoggedOut:$isLoggedOut");

    if (isLoggedOut != true) {
      return false;
    }

    stopUserSubscription();

    if (context != null && context.checkMounted() && context.mounted) {
      // CourseProvider courseProvider = context.read<CourseProvider>();
      // courseProvider.reset(isNotify: false);
    }

    try {
      Future.wait([
        GoogleSignIn().signOut().then((value) {
          MyPrint.printOnConsole("Logged Out User From Google Auth");
        }).catchError((e, s) {
          MyPrint.printOnConsole("Error in Logging Out User From Google:$e");
          MyPrint.printOnConsole(s);
        }),
        FirebaseAuth.instance.signOut().then((value) {
          MyPrint.printOnConsole("Logged Out User From Firebase Auth");
        }).catchError((e, s) {
          MyPrint.printOnConsole("Error in Logging Out User From Firebase:$e");
          MyPrint.printOnConsole(s);
        }),
      ]);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Logging Out:$e");
      MyPrint.printOnConsole(s);
    }

    isLoggedOut = true;

    if (isNavigateToLogin && context != null && context.checkMounted() && context.mounted) {
      if (isForceLogout) {
        Future.delayed(const Duration(seconds: 1), () {
          if (LoginScreen.context != null) {
            MyToast.showError(context: LoginScreen.context!, msg: forceLogoutMessage);
          }
        });
      }

      NavigationController.navigateToLoginScreen(
        navigationOperationParameters: NavigationOperationParameters(
          context: context,
          navigationType: NavigationType.pushNamedAndRemoveUntil,
        ),
      );
    }

    return isLoggedOut;
  }
}
