import 'package:eco_venture_admin_portal/models/modules_uploaded_model.dart';
import 'package:eco_venture_admin_portal/services/module_uplaoded_service.dart';

class ModuleRepo {
  ModuleRepo._();
  static final ModuleRepo instance = ModuleRepo._();

  /// Logic: Fetches the combined library from RTDB via the Service.
  Future<List<ModuleContentModel>> getModuleLibrary() async {
    return await ModuleService.instance.fetchAllModules();
  }
}