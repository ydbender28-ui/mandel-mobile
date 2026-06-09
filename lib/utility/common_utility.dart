import 'package:intl/intl.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

mixin CommonUtility {
  ///
  ///This method can be used for build endpoint url concat url with base url
  String buildUrl(String url) {
    return CommonConstants.mandelBaseUrl + url;
  }

  ///
  ///This method will return time stamp string
  String getCurrentTimeStampText() {
    final dt = DateTime.now();
    final date = DateFormat('E d y').format(dt);
    final time = DateFormat('jms').format(dt);

    return '$date $time';
  }

  String getFormattedTimeStamp(timestamp) {
    if (timestamp != null) {
      final date = DateFormat('E d y').format(timestamp);
      final time = DateFormat('jms').format(timestamp);

      return '$date $time';
    } else {
      return '';
    }
  }
}
