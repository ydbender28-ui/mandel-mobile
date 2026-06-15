import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/db/entity/configs_entity.dart';
import 'package:mandel_mobile_app/db/repository/configs_repository.dart';
import 'package:mandel_mobile_app/model/scanner_arguments.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

mixin BarcodeScannerUtility {
  void navigateToDefaultScanner(
      BuildContext context, ScannerArguments arguments) async {
    // sqflite and flutter_blue_plus don't work on web — always use camera scanner
    if (kIsWeb) {
      Navigator.of(context).pushNamed(CommonConstants.cameraBrcodeScannerUrl,
          arguments: arguments);
      return;
    }

    final ConfigsRepository configsRepository = ConfigsRepository();
    ConfigsEntity defaultScannerConfig = await configsRepository
        .getSingleConfigByKey(CommonConstants.defaultBarcodeScannerConfigKey);

    if (!context.mounted) return;

    if (CommonConstants.cammeraScanner == defaultScannerConfig.value) {
      Navigator.of(context).pushNamed(CommonConstants.cameraBrcodeScannerUrl,
          arguments: arguments);
    } else {
      Navigator.of(context).pushNamed(CommonConstants.productScannerScreenUrl,
          arguments: arguments);
    }
  }
}
