import 'package:smart_catering_service/configs/constants.dart';
import 'package:smart_catering_service/configs/typedefs.dart';
import 'package:smart_catering_service/models/common/data_model/property_model.dart';
import 'package:smart_catering_service/utils/extensions.dart';
import 'package:smart_catering_service/utils/my_print.dart';
import 'package:smart_catering_service/utils/my_utils.dart';

class AdminRepository {
  Future<PropertyModel?> getPropertyModel() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminRepository().getPropertyModel() called", tag: tag);

    PropertyModel? propertyModel;
    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.adminPropertyDocumentReference.get();
      MyPrint.printOnConsole("Property Snapshot Data:${snapshot.data()}", tag: tag);

      if(snapshot.exists && snapshot.data().checkNotEmpty) {
        propertyModel = PropertyModel.fromMap(snapshot.data()!);
      }

      MyPrint.printOnConsole("propertyModel:$propertyModel", tag: tag);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in AdminRepository().getPropertyModel():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return propertyModel;
  }
}