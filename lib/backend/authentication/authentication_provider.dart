import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_catering_service/models/admin_user/data_model/admin_user_model.dart';

import '../../configs/typedefs.dart';
import '../../models/user/data_model/user_model.dart';
import '../common/common_provider.dart';

class AuthenticationProvider extends CommonProvider {
  AuthenticationProvider() {
    firebaseUser = CommonProviderPrimitiveParameter<User?>(
      value: null,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
    email = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
    adminUserModel = CommonProviderPrimitiveParameter<AdminUserModel?>(
      value: null,
      notify: notify,
    );
    userModel = CommonProviderPrimitiveParameter<UserModel?>(
      value: null,
      notify: notify,
    );
  }

  late CommonProviderPrimitiveParameter<User?> firebaseUser;
  late CommonProviderPrimitiveParameter<String> userId;
  late CommonProviderPrimitiveParameter<String> email;
  late CommonProviderPrimitiveParameter<AdminUserModel?> adminUserModel;
  late CommonProviderPrimitiveParameter<UserModel?> userModel;
  //region Logged In Admin User Stream Subscription
  MyFirestoreDocumentSnapshotStreamSubscription? _userStreamSubscription;

  MyFirestoreDocumentSnapshotStreamSubscription? get userStreamSubscription => _userStreamSubscription;

  void setUserStreamSubscription({MyFirestoreDocumentSnapshotStreamSubscription? subscription, bool isCancelPreviousSubscription = true, bool isNotify = true,}) {
    if(isCancelPreviousSubscription) {
      stopUserStreamSubscription(isNotify: false);
    }
    _userStreamSubscription = subscription;
    notify(isNotify: isNotify);
  }

  void stopUserStreamSubscription({bool isNotify = true,}) {
    _userStreamSubscription?.cancel();
    _userStreamSubscription = null;
    notify(isNotify: isNotify);
  }
  //endregion

  void setAuthenticationDataFromFirebaseUser({
    User? firebaseUser,
    bool isNotify = true,
  }) {
    this.firebaseUser.set(value: firebaseUser, isNotify: false);
    userId.set(value: firebaseUser?.uid ?? "", isNotify: false);
    email.set(value: firebaseUser?.email ?? "", isNotify: isNotify);
  }

  void resetData({bool isNotify = true}) {
    firebaseUser.set(value: null, isNotify: false);
    userId.set(value: "", isNotify: false);
    email.set(value: "", isNotify: isNotify);
    adminUserModel.set(value: null, isNotify: isNotify);
    userModel.set(value: null, isNotify: isNotify);
  }
}