import 'package:mandel_mobile_app/db/entity/configs_entity.dart';
import 'package:mandel_mobile_app/db/repository/configs_repository.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';
import 'package:package_info_plus/package_info_plus.dart';

class TelemetryService with CommonUtility {
  final ConfigsRepository configsRepository = ConfigsRepository();

  sendHeartbeatTelemetry() async {
    ConfigsEntity lastCatalogSyncConfig = await configsRepository
        .getSingleConfigByKey(CommonConstants.catalogueSyncTimeConfigKey);
    final PackageInfo info = await PackageInfo.fromPlatform();
    final entry = {
      "event": "HEARTBEAT",
      'timeStamp': DateTime.now().toUtc().microsecondsSinceEpoch,
      'data': {
        'lastCatalogueSync': lastCatalogSyncConfig.value,
        'lastCatalogueSyncStatus': 'SUCCESS',
        'version': info.version,
        'buildNumber': info.buildNumber,
        'buildSignature': info.buildSignature,
        'installerStore': info.installerStore
      }
    };
    await DioClient().dio.post(buildUrl("/device-telemetry"), data: entry);
  }
}
